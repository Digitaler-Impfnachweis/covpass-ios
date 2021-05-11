//
//  VaccinationRepository.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

import Foundation
import Keychain
import PromiseKit

public struct VaccinationRepository: VaccinationRepositoryProtocol {
    private let service: APIServiceProtocol
    private let parser: QRCoderProtocol
    private let certificateSignatures: [String]

    public init(service: APIServiceProtocol, parser: QRCoderProtocol) {
        self.service = service
        self.parser = parser
        certificateSignatures = XCConfiguration.value([String].self, forKey: "CA_CERTIFICATE_SIGNATURES")
    }

    public func getVaccinationCertificateList() -> Promise<VaccinationCertificateList> {
        return Promise { seal in
            do {
                guard let data = try Keychain.fetchPassword(for: KeychainConfiguration.vaccinationCertificateKey) else {
                    throw KeychainError.fetch
                }
                let certificate = try JSONDecoder().decode(VaccinationCertificateList.self, from: data)
                seal.fulfill(certificate)
            } catch {
                if case KeychainError.fetch = error {
                    seal.fulfill(VaccinationCertificateList(certificates: []))
                    return
                }
                throw error
            }
        }
    }

    public func saveVaccinationCertificateList(_ certificateList: VaccinationCertificateList) -> Promise<VaccinationCertificateList> {
        return Promise { seal in
            let data = try JSONEncoder().encode(certificateList)
            try Keychain.storePassword(data, for: KeychainConfiguration.vaccinationCertificateKey)
            seal.fulfill(certificateList)
        }
    }

    public func refreshValidationCA() -> Promise<Void> {
        // TOOD add implementation
        return Promise.value(())
    }

    public func scanVaccinationCertificate(_ data: String) -> Promise<ExtendedCBORWebToken> {
        return parser.parse(data).map { certificate in
            ExtendedCBORWebToken(vaccinationCertificate: certificate, vaccinationQRCodeData: data)
        }.then { extendedCBORWebToken in
            self.getVaccinationCertificateList().then { list -> Promise<Void> in
                var certList = list
                if certList.certificates.contains(where: { $0.vaccinationQRCodeData == data }) {
                    throw QRCodeError.qrCodeExists
                }
                certList.certificates.append(extendedCBORWebToken)

                // Mark first certificate as favorite
                if certList.certificates.count == 1 {
                    certList.favoriteCertificateId = extendedCBORWebToken.vaccinationCertificate.hcert.dgc.v.first?.ci
                }

                return self.saveVaccinationCertificateList(certList).asVoid()
            }
            .map { extendedCBORWebToken }
            .then { token in
                Promise { seal in
                    self.reissueValidationCertificate(token)
                        .done { extendedToken in
                            seal.fulfill(extendedToken)
                        }
                        .catch { _ in
                            seal.fulfill(token)
                        }
                }
            }
        }
    }

    public func reissueValidationCertificate(_ certificate: ExtendedCBORWebToken) -> Promise<ExtendedCBORWebToken> {
        return service.reissue(certificate.vaccinationQRCodeData).map { validationCert in
            var cert = certificate
            cert.validationQRCodeData = validationCert
            return cert
        }.then { cert in
            self.getVaccinationCertificateList().map { list in
                var certList = list
                certList.certificates = certList.certificates.map {
                    if $0 == cert {
                        return cert
                    }
                    return $0
                }
                return certList
            }.then(self.saveVaccinationCertificateList).map { _ in
                cert
            }
        }
    }

    public func checkValidationCertificate(_ data: String) -> Promise<CBORWebToken> {
        firstly {
            parser.parse(data)
        }
        .map { token in
            let payload = data.stripPrefix()
            let base45Decoded = try Base45Coder().decode(payload)
            guard let decompressedPayload = Compression.decompress(Data(base45Decoded)) else {
                throw ApplicationError.general("Could not decompress QR Code data")
            }

            guard let cosePayload = try CoseSign1Parser().parse(decompressedPayload),
                  HCert().verify(message: cosePayload, certificatePaths: certificateSignatures)
            else {
                throw HCertError.verifyError
            }
            return token
        }
    }
}
