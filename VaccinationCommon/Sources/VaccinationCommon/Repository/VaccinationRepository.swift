//
//  VaccinationRepository.swift
//  
//
//  Copyright © 2021 IBM. All rights reserved.
//

import Foundation
import PromiseKit
import Keychain

public protocol VaccinationRepositoryProtocol {
    // Return the vaccination certificate list
    func getVaccinationCertificateList() -> Promise<VaccinationCertificateList>

    // Save the vaccination certificate list
    func saveVaccinationCertificateList(_ certificateList: VaccinationCertificateList) -> Promise<VaccinationCertificateList>

    // Refreshes the local validation CA
    func refreshValidationCA() -> Promise<Void>

    // scanVaccinationCertificate validates the given QR code, parses it, interacts with the HealthCertificateBackend to retrieve the ValidationCertificate and returns everything as an ExtendedVaccinationCertificate.
    //
    // If an error occurs, the method will not return a certificate but an error
    //
    // - USED BY VaccinationPass App
    func scanVaccinationCertificate(_ data: String) -> Promise<ExtendedVaccinationCertificate>

    // reissueValidationCertificate will send the vaccination certificate to the backend to issue a new validation certificate
    //
    // - USED BY VaccinationPass App
    func reissueValidationCertificate(_ certificate: ExtendedVaccinationCertificate) -> Promise<ExtendedVaccinationCertificate>

    // checkValidationCertificate validates the given QR code and returns the ValidationCertificate when it's valid, otherwise an error
    //
    // - USED BY VaccinationValidator App
    func checkValidationCertificate(_ data: String) -> Promise<ValidationCertificate>
}

public struct VaccinationRepository: VaccinationRepositoryProtocol {

    private let service: APIServiceProtocol
    private let parser: QRCoderProtocol

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

    public func refreshValidationCA() -> Promise<Void> {
        // TOOD add implementation
        return Promise.value(())
    }

    public func scanVaccinationCertificate(_ data: String) -> Promise<ExtendedVaccinationCertificate> {
        return self.parser.parse(data).map({ certificate in
            return ExtendedVaccinationCertificate(vaccinationCertificate: certificate, vaccinationQRCodeData: data, validationQRCodeData: nil)
        }).then({ extendedVaccinationCertificate in
            return self.getVaccinationCertificateList().then({ list -> Promise<Void> in
                var certList = list
                if certList.certificates.contains(where: { $0.vaccinationQRCodeData == data }) {
                    throw QRCodeError.qrCodeExists
                }
                certList.certificates.append(extendedVaccinationCertificate)

                // Mark first certificate as favorite
                if certList.certificates.count == 1 {
                    certList.favoriteCertificateId = extendedVaccinationCertificate.vaccinationCertificate.id
                }

                return self.saveVaccinationCertificateList(certList).asVoid()
            }).map({ return extendedVaccinationCertificate })
        })
    }

    public func reissueValidationCertificate(_ certificate: ExtendedVaccinationCertificate) -> Promise<ExtendedVaccinationCertificate> {
        return self.service.reissue(certificate.vaccinationQRCodeData).map({ validationCert in
            var cert = certificate
            cert.validationQRCodeData = validationCert
            return cert
        }).then({ cert in
            return self.getVaccinationCertificateList().map({ list in
                var certList = list
                certList.certificates = certList.certificates.map({
                    if $0 == cert {
                        return cert
                    }
                    return $0
                })
                return certList
            }).then(self.saveVaccinationCertificateList).map({ _ in
                return cert
            })
        })
    }

    public func checkValidationCertificate(_ data: String) -> Promise<ValidationCertificate> {
        return self.parser.parse(data)
    }
}
