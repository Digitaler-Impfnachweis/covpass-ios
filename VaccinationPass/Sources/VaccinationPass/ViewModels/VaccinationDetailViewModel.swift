//
//  VaccinationDetailViewModel.swift
//  
//
//  Copyright © 2021 IBM. All rights reserved.
//

import UIKit
import VaccinationUI
import VaccinationCommon
import PromiseKit

public class VaccinationDetailViewModel {

    private let parser = QRCoder()
    private var service = VaccinationCertificateService()

    private var certificates: [ExtendedVaccinationCertificate]

    public init(certificates: [ExtendedVaccinationCertificate]) {
        self.certificates = certificates
    }

    public var partialVaccination: Bool {
        return certificates.map({ $0.vaccinationCertificate.partialVaccination }).first(where: { !$0 }) ?? true
    }

    public var isFavorite: Bool {
        do {
            let certList = try service.fetch().wait()
            return certificates.contains(where: { $0.vaccinationCertificate.id == certList.favoriteCertificateId })
        } catch {
            print(error)
            return false
        }
    }

    public var name: String {
        return certificates.first?.vaccinationCertificate.name ?? ""
    }

    public var birthDate: String {
        guard let date = certificates.first?.vaccinationCertificate.birthDate else { return "" }
        return DateUtils.displayDateFormatter.string(from: date)
    }
    
    public var immunizationIcon: UIImage? {
        return UIImage(named: partialVaccination ? "status_partial" : "status_full", in: UIConstants.bundle, compatibleWith: nil)
    }
    
    public var immunizationTitle: String {
        return partialVaccination ? "vaccination_detail_immunization_partial_title".localized : "vaccination_detail_immunization_full_title".localized
    }
    
    public var immunizationBody: String {
        return partialVaccination ? "vaccination_detail_immunization_1_body".localized : "vaccination_detail_immunization_2_body".localized
    }
    
    public var immunizationButton: String {
        return partialVaccination ? "vaccination_detail_immunization_1_button".localized : "vaccination_detail_immunization_2_button".localized
    }

    public var vaccinations: [VaccinationViewModel] {
        return certificates.map({ VaccinationViewModel(certificate: $0.vaccinationCertificate) })
    }

    public func delete() -> Promise<Void> {
        service.fetch().then({ list -> Promise<VaccinationCertificateList> in
            var certList = list
            certList.certificates.removeAll(where: { certificate in
                for cert in self.certificates where cert == certificate {
                    return true
                }
                return false
            })
            return Promise.value(certList)
        }).then({ list in
            self.service.save(list)
        })
    }

    public func updateFavorite() -> Promise<Void> {
        return service.fetch().map({ cert in
            var certList = cert
            guard let id = self.certificates.first?.vaccinationCertificate.id else {
                return certList
            }
            certList.favoriteCertificateId = certList.favoriteCertificateId == id ? nil : id
            return certList
        }).then({ cert in
            return self.service.save(cert)
        })
    }

    public func process(payload: String) -> Promise<Void> {
        return Promise<ExtendedVaccinationCertificate>() { seal in
            // TODO refactor parser
            guard let decodedPayload: VaccinationCertificate = parser.parse(payload, completion: { error in
                seal.reject(error)
            }) else {
                seal.reject(ApplicationError.unknownError)
                return
            }
            seal.fulfill(ExtendedVaccinationCertificate(vaccinationCertificate: decodedPayload, vaccinationQRCodeData: payload, validationQRCodeData: nil))
        }.then({ extendedVaccinationCertificate in
            return self.service.fetch().then({ list -> Promise<Void> in
                var certList = list
                if certList.certificates.contains(where: { $0.vaccinationQRCodeData == payload }) {
                    throw QRCodeError.qrCodeExists
                }
                certList.certificates.append(extendedVaccinationCertificate)
                return self.service.save(certList)
            }).then(self.service.fetch).done({ list in
                self.certificates = self.findCertificatePair(extendedVaccinationCertificate, list.certificates)
            })
        })
    }

    private func findCertificatePair(_ certificate: ExtendedVaccinationCertificate, _ certificates: [ExtendedVaccinationCertificate]) -> [ExtendedVaccinationCertificate] {
        var list = [certificate]
        for cert in certificates where certificate.vaccinationCertificate == cert.vaccinationCertificate {
            if !list.contains(cert) {
                list.append(cert)
            }
        }
        return list
    }
}
