//
//  CertificateItemDetailViewModel.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

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

    var showSubtitle: Bool {
        dgc.v?.first?.dn == 1 && dgc.v?.first?.sd == 1
    }

    var headline: String {
        if dgc.r != nil {
            return "recovery_certificate_detail_view_headline".localized
        }
        if dgc.t != nil {
            return "test_certificate_detail_view_headline".localized
        }
        return "vaccination_certificate_detail_view_vaccination_headline".localized
    }

    var isExpired: Bool {
        certificate.vaccinationCertificate.isExpired
    }

    var expiresSoonDate: Date? {
        if certificate.vaccinationCertificate.expiresSoon {
            return certificate.vaccinationCertificate.exp
        }
        return nil
    }

    var isInvalid: Bool {
        certificate.vaccinationCertificate.isInvalid
    }

    private var dob: String {
        return DateUtils.displayIsoDateOfBirth(dgc)
    }

    var items: [ContentItem] {
        if let r = dgc.r?.first {
            return [
                ContentItem("recovery_certificate_detail_view_data_name".localized, dgc.nam.fullNameReverse),
                ContentItem("recovery_certificate_detail_view_data_name_standard".localized, dgc.nam.fullNameTransliteratedReverse),
                ContentItem("recovery_certificate_detail_view_data_date_of_birth".localized, dob,
                            accessibilityLabel(for: dob, label: "recovery_certificate_detail_view_data_date_of_birth".localized)),
                ContentItem("recovery_certificate_detail_view_data_disease".localized, r.tgDisplayName),
                ContentItem("recovery_certificate_detail_view_data_date_first_positive_result".localized, DateUtils.isoDateFormatter.string(from: r.fr),
                            accessibilityLabel(for: r.fr, label: "recovery_certificate_detail_view_data_date_first_positive_result".localized)),
                ContentItem("recovery_certificate_detail_view_data_country".localized, r.co.localized),
                ContentItem("recovery_certificate_detail_view_data_issuer".localized, r.is),
                ContentItem("recovery_certificate_detail_view_data_valid_from".localized, DateUtils.isoDateFormatter.string(from: r.df),
                            accessibilityLabel(for: r.df, label: "recovery_certificate_detail_view_data_valid_from".localized)),
                ContentItem("recovery_certificate_detail_view_data_valid_until".localized, DateUtils.isoDateFormatter.string(from: r.du),
                            accessibilityLabel(for: r.du, label: "recovery_certificate_detail_view_data_valid_until".localized)),
                ContentItem("recovery_certificate_detail_view_data_identifier".localized, r.ciDisplayName),
                ContentItem("recovery_certificate_detail_view_data_expiry_date".localized, String(format: "\("recovery_certificate_detail_view_data_expiry_date_message".localized)\n\("recovery_certificate_detail_view_data_expiry_date_note".localized)", certificate.vaccinationCertificate.exp != nil ? DateUtils.displayDateTimeFormatter.string(from: certificate.vaccinationCertificate.exp!) : "") /* TODO: accessibility label */ )
            ]
        }
        if let t = dgc.t?.first {
            return [
                ContentItem("test_certificate_detail_view_data_name".localized, dgc.nam.fullNameReverse),
                ContentItem("test_certificate_detail_view_data_name_standard".localized, dgc.nam.fullNameTransliteratedReverse),
                ContentItem("test_certificate_detail_view_data_date_of_birth".localized, dob,
                            accessibilityLabel(for: dob, label: "test_certificate_detail_view_data_date_of_birth".localized)),
                ContentItem("test_certificate_detail_view_data_disease".localized, t.tgDisplayName),
                ContentItem("test_certificate_detail_view_data_test_type".localized, t.ttDisplayName),
                ContentItem("test_certificate_detail_view_data_test_name".localized, t.nm ?? ""),
                ContentItem("test_certificate_detail_view_data_test_manufactur".localized, t.maDisplayName ?? ""),
                ContentItem("test_certificate_detail_view_data_test_date_and_time".localized, DateUtils.displayIsoDateTimeFormatter.string(from: t.sc),
                            accessibilityLabel(for: t.sc, label: "test_certificate_detail_view_data_test_date_and_time".localized, includesTime: true)),
                ContentItem("test_certificate_detail_view_data_test_results".localized, t.trDisplayName),
                ContentItem("test_certificate_detail_view_data_test_centre".localized, t.tc),
                ContentItem("test_certificate_detail_view_data_test_country".localized, t.co.localized),
                ContentItem("test_certificate_detail_view_data_test_issuer".localized, t.is),
                ContentItem("test_certificate_detail_view_data_test_identifier".localized, t.ciDisplayName),
                ContentItem("test_certificate_detail_view_data_expiry_date".localized,
                            String(format: "\("test_certificate_detail_view_data_expiry_date_message".localized)\n\("test_certificate_detail_view_data_expiry_date_note".localized)", certificate.vaccinationCertificate.exp != nil ? DateUtils.displayDateTimeFormatter.string(from: certificate.vaccinationCertificate.exp!) : "") /* TODO: accessibility label */ )
            ]
        }
        if let v = dgc.v?.first {
            return [
                ContentItem("vaccination_certificate_detail_view_data_name".localized, dgc.nam.fullNameReverse),
                ContentItem("vaccination_certificate_detail_view_data_name_standard".localized, dgc.nam.fullNameTransliteratedReverse),
                ContentItem("vaccination_certificate_detail_view_data_date_of_birth".localized, dob,
                            accessibilityLabel(for: dob, label: "vaccination_certificate_detail_view_data_date_of_birth".localized)),
                ContentItem("vaccination_certificate_detail_view_data_disease".localized, v.tgDisplayName),
                ContentItem("vaccination_certificate_detail_view_data_vaccine".localized, v.map(key: v.mp, from: Bundle.commonBundle.url(forResource: "vaccine-medicinal-product", withExtension: "json")) ?? v.mp),
                ContentItem("vaccination_certificate_detail_view_data_vaccine_type".localized, v.vpDisplayName),
                ContentItem("vaccination_certificate_detail_view_data_vaccine_manufactur".localized, v.maDisplayName),
                ContentItem("vaccination_certificate_detail_view_data_vaccine_number".localized, "\(v.dn) / \(v.sd)"),
                ContentItem("vaccination_certificate_detail_view_data_vaccine_date_".localized, DateUtils.isoDateFormatter.string(from: v.dt),
                            accessibilityLabel(for: v.dt, label: "vaccination_certificate_detail_view_data_vaccine_date_".localized)),
                ContentItem("vaccination_certificate_detail_view_data_vaccine_country".localized, v.co.localized),
                ContentItem("vaccination_certificate_detail_view_data_vaccine_issuer".localized, v.is),
                ContentItem("vaccination_certificate_detail_view_data_vaccine_identifier".localized, v.ciDisplayName),
                ContentItem("vaccination_certificate_detail_view_data_expiry_date".localized,
                            String(format: "\("vaccination_certificate_detail_view_data_expiry_date_message".localized)\n\("vaccination_certificate_detail_view_data_expiry_date_note".localized)", certificate.vaccinationCertificate.exp != nil ? DateUtils.displayDateTimeFormatter.string(from: certificate.vaccinationCertificate.exp!) : "" /* TODO: accessibility label */ ))
            ]
        }
        return []
    }

    var canExportToPDF: Bool {
        certificate.canExportToPDF
    }

    var vaasResultToken: VAASValidaitonResultToken?
    var hasValidationResult: Bool {
        vaasResultToken != nil
    }

    // MARK: - Lifecyle

    init(
        router: CertificateItemDetailRouterProtocol,
        repository: VaccinationRepositoryProtocol,
        certificate: ExtendedCBORWebToken,
        resolvable: Resolver<CertificateDetailSceneResult>?,
        vaasResultToken: VAASValidaitonResultToken?
    ) {
        self.router = router
        self.repository = repository
        self.certificate = certificate
        resolver = resolvable
        self.vaasResultToken = vaasResultToken
    }

    // MARK: - Methods

    func deleteCertificate() {
        firstly {
            showDeleteDialog()
        }
        .then {
            self.repository.delete(self.certificate)
        }
        .done {
            self.resolver?.fulfill(.didDeleteCertificate)
        }
        .catch { error in
            self.router.showUnexpectedErrorDialog(error)
        }
    }

    func showQRCode() {
        router.showCertificate(for: certificate).cauterize()
    }

    func startPDFExport() {
        router.showPDFExport(for: certificate).cauterize()
    }

    private func showDeleteDialog() -> Promise<Void> {
        .init { seal in
            let delete = DialogAction(title: "dialog_delete_certificate_button_delete".localized, style: .destructive) { _ in
                seal.fulfill_()
            }
            let cancel = DialogAction(title: "dialog_delete_certificate_button_cancel".localized, style: .cancel) { _ in
                seal.cancel()
            }
            self.router.showDialog(
                title: "dialog_delete_certificate_title".localized,
                message: "dialog_delete_certificate_message".localized,
                actions: [delete, cancel],
                style: .alert
            )
        }
    }

    // MARK: - Accessibility

    private func accessibilityLabel(for dateString: String, label: String) -> String {
        let dateStr = DateUtils.audioDate(dateString) ?? dateString
        return "\(label)\n\(dateStr)"
    }

    private func accessibilityLabel(for date: Date, label: String, includesTime: Bool = false) -> String {
        let formatter = includesTime ? DateUtils.displayDateTimeFormatter : DateUtils.audioDateFormatter
        let dateStr = formatter.string(from: date)
        return "\(label)\n\(dateStr)"
    }
}
