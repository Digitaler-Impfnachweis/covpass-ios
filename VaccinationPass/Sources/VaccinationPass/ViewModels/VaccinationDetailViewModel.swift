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

    private let repository: VaccinationRepositoryProtocol
    private var certificates: [ExtendedVaccinationCertificate]

    public init(certificates: [ExtendedVaccinationCertificate], repository: VaccinationRepositoryProtocol) {
        self.certificates = certificates
        self.repository = repository
    }

    public var partialVaccination: Bool {
        return certificates.map({ $0.vaccinationCertificate.partialVaccination }).first(where: { !$0 }) ?? true
    }

    public var isFavorite: Bool {
        do {
            let certList = try repository.getVaccinationCertificateList().wait()
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
        return repository.getVaccinationCertificateList().then({ list -> Promise<VaccinationCertificateList> in
            var certList = list
            certList.certificates.removeAll(where: { certificate in
                for cert in self.certificates where cert == certificate {
                    return true
                }
                return false
            })
            return Promise.value(certList)
        }).then({ list in
            return self.repository.saveVaccinationCertificateList(list).asVoid()
        })
    }

    public func updateFavorite() -> Promise<Void> {
        return repository.getVaccinationCertificateList().map({ cert in
            var certList = cert
            guard let id = self.certificates.first?.vaccinationCertificate.id else {
                return certList
            }
            certList.favoriteCertificateId = certList.favoriteCertificateId == id ? nil : id
            return certList
        }).then({ cert in
            return self.repository.saveVaccinationCertificateList(cert).asVoid()
        })
    }

    public func process(payload: String) -> Promise<Void> {
        return repository.scanVaccinationCertificate(payload).then({ cert in
            return self.repository.getVaccinationCertificateList().then({ list -> Promise<Void> in
                self.certificates = self.findCertificatePair(cert, list.certificates)
                return Promise.value(())
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
