//
//  CertificateItemDetailViewModel.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import PromiseKit
import UIKit
import CovPassCommon
import CovPassUI
import PromiseKit
import UIKit

class CertificateItemDetailViewModel: CertificateItemDetailViewModelProtocol {
    // MARK: - Properties

    let router: CertificateItemDetailRouterProtocol
    private let repository: VaccinationRepositoryProtocol
    private var certificate: ExtendedCBORWebToken
    private var dgc: DigitalGreenCertificate {
        certificate.vaccinationCertificate.hcert.dgc
    }
    private let resolver: Resolver<CertificateDetailSceneResult>?

    var title: String {
        if dgc.r != nil {
            return "recovery_certificate_detail_view_title".localized
        }
        if let t = dgc.t?.first {
            return t.isPCR ? "test_certificate_detail_view_pcr_test_title".localized : "test_certificate_detail_view_title".localized
        }
        return String(format: "vaccination_certificate_detail_view_vaccination_title".localized, dgc.v?.first?.dn ?? 0, dgc.v?.first?.sd ?? 0)
    }

    var headline: String {
        if dgc.r != nil {
            return "recovery_certificate_detail_view_headline".localized
        }
        if dgc.t != nil {
            return "recovery_certificate_detail_view_headline".localized
        }
        return "vaccination_certificate_detail_view_vaccination_headline".localized
    }

    var items: [(String, String)] {
        if let r = dgc.r?.first {
            return [
                ("recovery_certificate_detail_view_data_name".localized, dgc.nam.fullName),
                ("recovery_certificate_detail_view_data_date_of_birth".localized, DateUtils.displayDateFormatter.string(from: dgc.dob ?? Date())),
                ("recovery_certificate_detail_view_data_disease".localized, r.map(key: r.tg, from: Bundle.commonBundle.url(forResource: "disease-agent-targeted", withExtension: "json")) ?? r.tg),
                ("recovery_certificate_detail_view_data_date_first_positive_result".localized, DateUtils.displayDateFormatter.string(from: r.fr)),
                ("recovery_certificate_detail_view_data_country".localized, r.co),
                ("recovery_certificate_detail_view_data_issuer".localized, r.is),
                ("recovery_certificate_detail_view_data_valid_from".localized, DateUtils.displayDateFormatter.string(from: r.df)),
                ("recovery_certificate_detail_view_data_valid_until".localized, DateUtils.displayDateFormatter.string(from: r.du)),
                ("recovery_certificate_detail_view_data_identifier".localized, r.ci),
            ]
        }
        if let t = dgc.t?.first {
            return [
                ("test_certificate_detail_view_data_name".localized, dgc.nam.fullName),
                ("test_certificate_detail_view_data_date_of_birth".localized, DateUtils.displayDateFormatter.string(from: dgc.dob ?? Date())),
                ("test_certificate_detail_view_data_disease".localized, t.map(key: t.tg, from: Bundle.commonBundle.url(forResource: "disease-agent-targeted", withExtension: "json")) ?? t.tg),
                ("test_certificate_detail_view_data_test_type".localized, t.map(key: t.tt, from: Bundle.commonBundle.url(forResource: "test-type", withExtension: "json")) ?? t.tt),
                ("test_certificate_detail_view_data_test_name".localized, t.nm ?? ""),
                ("test_certificate_detail_view_data_test_manufactur".localized, t.map(key: t.ma, from: Bundle.commonBundle.url(forResource: "test-manf", withExtension: "json")) ?? t.ma ?? ""),
                ("test_certificate_detail_view_data_test_date_and_time".localized, DateUtils.displayDateFormatter.string(from: t.sc)),
                ("test_certificate_detail_view_data_test_results".localized, t.map(key: t.tr, from: Bundle.commonBundle.url(forResource: "test-result", withExtension: "json")) ?? t.tr),
                ("test_certificate_detail_view_data_test_centre".localized, t.tc),
                ("test_certificate_detail_view_data_test_country".localized, t.co),
                ("test_certificate_detail_view_data_test_issuer".localized, t.is),
                ("test_certificate_detail_view_data_test_identifier".localized, t.ci),
            ]
        }
        if let v = dgc.v?.first {
            return [
                ("vaccination_certificate_detail_view_data_name".localized, dgc.nam.fullName),
                ("vaccination_certificate_detail_view_data_date_of_birth".localized, DateUtils.displayDateFormatter.string(from: dgc.dob ?? Date())),
                ("vaccination_certificate_detail_view_data_disease".localized, v.map(key: v.tg, from: Bundle.commonBundle.url(forResource: "disease-agent-targeted", withExtension: "json")) ?? v.tg),
                ("vaccination_certificate_detail_view_data_vaccine".localized, v.map(key: v.mp, from: Bundle.commonBundle.url(forResource: "vaccine-medicinal-product", withExtension: "json")) ?? v.mp),
                ("vaccination_certificate_detail_view_data_vaccine_type".localized, v.map(key: v.vp, from: Bundle.commonBundle.url(forResource: "vaccine-prophylaxis", withExtension: "json")) ?? v.vp),
                ("vaccination_certificate_detail_view_data_vaccine_manufactur".localized, v.map(key: v.ma, from: Bundle.commonBundle.url(forResource: "vaccine-mah-manf", withExtension: "json")) ?? v.ma),
                ("vaccination_certificate_detail_view_data_vaccine_number".localized, "\(v.dn) / \(v.sd)"),
                ("vaccination_certificate_detail_view_data_vaccine_date_".localized, DateUtils.displayDateFormatter.string(from: v.dt)),
                ("vaccination_certificate_detail_view_data_vaccine_country".localized, v.map(key: v.co, from: Bundle.commonBundle.url(forResource: "country", withExtension: "json")) ?? v.co),
                ("vaccination_certificate_detail_view_data_vaccine_issuer".localized, v.is),
                ("vaccination_certificate_detail_view_data_vaccine_identifier".localized, v.ci),
            ]
        }
        return []
    }

    // MARK: - Lifecyle

    init(
        router: CertificateItemDetailRouterProtocol,
        repository: VaccinationRepositoryProtocol,
        certificate: ExtendedCBORWebToken,
        resolvable: Resolver<CertificateDetailSceneResult>?
    ) {
        self.router = router
        self.repository = repository
        self.certificate = certificate
        resolver = resolvable
    }

    // MARK: - Methods

    private func showErrorDialog() {
        router.showUnexpectedErrorDialog()
    }

    private func delete(_ vaccination: Vaccination) {
//        guard let certificate = certificates.first(for: vaccination) else {
//            showErrorDialog()
//            return
//        }
//        firstly {
//            showDeleteDialog(vaccination)
//        }
//        .then {
//            self.repository.delete(vaccination)
//        }
//        .then {
//            self.repository.getVaccinationCertificateList()
//        }
//        .map {
//            $0.certificates.pairableCertificates(for: certificate)
//        }
//        .done {
//            self.didUpdateCertificatesAfterDeletion($0)
//        }
//        .catch {
//            self.delegate?.viewModelUpdateDidFailWithError($0)
//        }
    }

//    private func showDeleteDialog(_ vaccination: Vaccination) -> Promise<Void> {
//        .init { seal in
//            let delete = DialogAction(title: "dialog_delete_certificate_button_delete".localized, style: .destructive) { _ in
//                seal.fulfill_()
//            }
//            let cancel = DialogAction(title: "dialog_delete_certificate_button_cancel".localized, style: .cancel) { _ in
//                seal.cancel()
//            }
//            self.router.showDialog(
//                title: String(format: "dialog_delete_certificate_title".localized, vaccination.dn, vaccination.sd),
//                message: "dialog_delete_certificate_message".localized,
//                actions: [delete, cancel],
//                style: .alert
//            )
//        }
//    }

    func showQRCode() {
        router.showCertificate(for: certificate).cauterize()
    }
}
