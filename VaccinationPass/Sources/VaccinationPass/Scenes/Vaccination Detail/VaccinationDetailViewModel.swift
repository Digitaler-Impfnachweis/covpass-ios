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

    private let router: VaccinationDetailRouterProtocol
    private let repository: VaccinationRepositoryProtocol
    private var certificates: [ExtendedCBORWebToken]

    public init(
        router: VaccinationDetailRouterProtocol,
        repository: VaccinationRepositoryProtocol,
        certificates: [ExtendedCBORWebToken]) {

        self.router = router
        self.repository = repository
        self.certificates = certificates.sorted(by: { $0.vaccinationCertificate.hcert.dgc.v.first?.dn ?? 0 < $1.vaccinationCertificate.hcert.dgc.v.first?.dn ?? 0 })
    }

    public var fullImmunization: Bool {
        certificates.map({ $0.vaccinationCertificate.hcert.dgc.fullImmunization }).first(where: { $0 }) ?? false
    }

    public var isFavorite: Bool {
        do {
            let certList = try repository.getVaccinationCertificateList().wait()
            return certificates.contains(where: { $0.vaccinationCertificate.hcert.dgc.v.first?.ci == certList.favoriteCertificateId })
        } catch {
            print(error)
            return false
        }
    }

    public var name: String {
        certificates.first?.vaccinationCertificate.hcert.dgc.nam.fullName ?? ""
    }

    public var birthDate: String {
        guard let date = certificates.first?.vaccinationCertificate.hcert.dgc.dob else { return "" }
        return DateUtils.displayDateFormatter.string(from: date)
    }
    
    public var immunizationIcon: UIImage? {
        UIImage(named: fullImmunization ? "status_full" : "status_partial", in: UIConstants.bundle, compatibleWith: nil)
    }
    
    public var immunizationTitle: String {
        fullImmunization ? "vaccination_certificate_detail_view_complete_title".localized : String(format: "vaccination_certificate_detail_view_incomplete_title".localized, 1, 2)
    }
    
    public var immunizationBody: String {
        fullImmunization ? "vaccination_certificate_detail_view_complete_message".localized : "vaccination_certificate_detail_view_incomplete_message".localized
    }
    
    public var immunizationButton: String {
        fullImmunization ? "vaccination_certificate_detail_view_complete_action_button_title".localized : "vaccination_certificate_detail_view_incomplete_action_button_title".localized
    }

    public var vaccinations: [VaccinationViewModel] {
        certificates.map({ VaccinationViewModel(token: $0.vaccinationCertificate) })
    }

    public func immunizationButtonTapped() {
        fullImmunization ?
            showCertificate() :
            scanNextCertificate()
    }

    private func scanNextCertificate() {
        firstly {
            router.showScanner()
        }
        .then { result -> Promise<Void> in
            switch result {
            case .success(let qrCode):
                return self.process(payload: qrCode)
            case.failure(let error):
                throw error
            }
        }
        .cauterize()
    }

    private func showCertificate() {
        router.showCertificateOverview()
    }

    public func delete() {
        firstly {
            showDeleteDialog()
        }
        .then {
            self.repository.getVaccinationCertificateList()
        }
        .then { list -> Promise<VaccinationCertificateList> in
            var certList = list
            certList.certificates.removeAll(where: { certificate in
                for cert in self.certificates where cert == certificate {
                    return true
                }
                return false
            })
            return Promise.value(certList)
        }
        .then { list in
            self.repository.saveVaccinationCertificateList(list).asVoid()
        }
        .done {
            self.router.showCertificateOverview()
        }
        .catch { error in
            print(error)
            // TODO: Handle error
        }
    }

    public func updateFavorite() -> Promise<Void> {
        return repository.getVaccinationCertificateList().map({ cert in
            var certList = cert
            guard let id = self.certificates.first?.vaccinationCertificate.hcert.dgc.v.first?.ci else {
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

    private func findCertificatePair(_ certificate: ExtendedCBORWebToken, _ certificates: [ExtendedCBORWebToken]) -> [ExtendedCBORWebToken] {
        var list = [certificate]
        for cert in certificates where certificate.vaccinationCertificate.hcert.dgc == cert.vaccinationCertificate.hcert.dgc {
            if !list.contains(cert) {
                list.append(cert)
            }
        }
        return list
    }

    private func showDeleteDialog() -> Promise<Void> {
        .init { seal in
            let delete = DialogAction(title: "dialog_delete_certificate_button_delete".localized, style: .destructive) { _ in
                seal.fulfill_()
            }
            let cancel = DialogAction(title: "dialog_delete_certificate_button_cancel".localized, style: .cancel) { _ in
                seal.cancel()
            }
            let title = String(format: "dialog_delete_certificate_title".localized, self.name)
            self.router.showDialog(
                title: title,
                message: "dialog_delete_certificate_message".localized,
                actions: [delete, cancel],
                style: .alert
            )
        }
    }
}
