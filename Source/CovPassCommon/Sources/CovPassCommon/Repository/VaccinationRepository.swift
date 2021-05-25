//
//  VaccinationRepository.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import Keychain
import PromiseKit

public struct VaccinationRepository: VaccinationRepositoryProtocol {
    private let service: APIServiceProtocol
    private let parser: QRCoderProtocol

    private var trustList: TrustList? {
        guard let trustListData = try? Keychain.fetchPassword(for: KeychainConfiguration.trustListKey),
              let list = try? JSONDecoder().decode(TrustList.self, from: trustListData)
        else { return nil }
        return list
    }

    public init(service: APIServiceProtocol, parser: QRCoderProtocol) {
        self.service = service
        self.parser = parser
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

    public func deleteVaccination(_ vaccination: Vaccination) -> Promise<Void> {
        firstly {
            getVaccinationCertificateList()
        }
        .then { list -> Promise<VaccinationCertificateList> in
            var certList = list
            // delete favorite if needed
            if certList.favoriteCertificateId == vaccination.ci {
                certList.favoriteCertificateId = nil
            }
            certList.certificates.removeAll(where: { cert in
                cert.vaccinationCertificate.hcert.dgc.v.first?.ci == vaccination.ci
            })
            return Promise.value(certList)
        }
        .then { list -> Promise<VaccinationCertificateList> in
            saveVaccinationCertificateList(list)
        }
        .asVoid()
    }

    public func refreshValidationCA() -> Promise<Void> {
        // TOOD add implementation
        return Promise.value(())
    }

    public func scanVaccinationCertificate(_ data: String) -> Promise<ExtendedCBORWebToken> {
        firstly {
            parser.parse(data)
        }
        .map { certificate in
            let base45Decoded = try Base45Coder().decode(data.stripPrefix())
            guard let decompressedPayload = Compression.decompress(Data(base45Decoded)) else {
                throw ApplicationError.general("Could not decompress QR Code data")
            }
            guard let trustList = self.trustList else {
                throw ApplicationError.general("Missing TrustLIst")
            }
            guard let cosePayload = try CoseSign1Parser().parse(decompressedPayload),
                  HCert().verify(message: cosePayload, trustList: trustList)
            else {
                throw HCertError.verifyError
            }
            return certificate
        }
        .map { certificate in
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
        }
    }

    public func checkVaccinationCertificate(_ data: String) -> Promise<CBORWebToken> {
        firstly {
            parser.parse(data)
        }
        .map { token in
            let payload = data.stripPrefix()
            let base45Decoded = try Base45Coder().decode(payload)
            guard let decompressedPayload = Compression.decompress(Data(base45Decoded)) else {
                throw ApplicationError.general("Could not decompress QR Code data")
            }
            guard let trustList = self.trustList else {
                throw ApplicationError.general("Missing TrustLIst")
            }
            guard let cosePayload = try CoseSign1Parser().parse(decompressedPayload),
                  HCert().verify(message: cosePayload, trustList: trustList)
            else {
                throw HCertError.verifyError
            }
            return token
        }
    }

    public func toggleFavoriteStateForCertificateWithIdentifier(_ id: String) -> Promise<Bool> {
        firstly {
            getVaccinationCertificateList()
        }
        .map { list in
            var certList = list
            certList.favoriteCertificateId = certList.favoriteCertificateId == id ? nil : id
            return certList
        }
        .then { list in
            self.saveVaccinationCertificateList(list)
        }
        .map { list in
            list.favoriteCertificateId == id
        }
    }

    public func favoriteStateForCertificates(_ certificates: [ExtendedCBORWebToken]) -> Promise<Bool> {
        firstly {
            getVaccinationCertificateList()
        }
        .map { currentList in
            certificates.contains(where: { $0.vaccinationCertificate.hcert.dgc.v.first?.ci == currentList.favoriteCertificateId })
        }
    }
}
