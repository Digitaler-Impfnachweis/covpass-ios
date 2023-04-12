//
//  RuleCheckDetailViewModel.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CertLogic
import CovPassCommon
import CovPassUI
import PromiseKit
import UIKit

class RuleCheckDetailViewModel {
    // MARK: - Properties

    let router: RuleCheckDetailRouterProtocol
    let resolver: Resolver<Void>
    let result: CertificateResult
    let country: String
    let date: Date

    private var dgc: DigitalGreenCertificate {
        result.certificate.vaccinationCertificate.hcert.dgc
    }

    var title: String {
        result.certificate.vaccinationCertificate.hcert.dgc.nam.fullName
    }

    var subtitle: String {
        if dgc.t?.isEmpty == false {
            return "certificate_check_validity_detail_view_test_result_title".localized
        }
        if dgc.r?.isEmpty == false {
            return "certificate_check_validity_detail_view_recovery_result_title".localized
        }
        return "certificate_check_validity_detail_view_vaccination_result_title".localized
    }

    var resultIcon: UIImage {
        switch result.state {
        case .fail:
            return .error
        case .open:
            return .warning
        case .passed:
            return .validationCheckmark
        }
    }

    var resultColor: UIColor {
        switch result.state {
        case .fail:
            return .resultRed
        case .open:
            return .resultYellow
        case .passed:
            return .resultGreen
        }
    }

    var resultColorBackground: UIColor {
        switch result.state {
        case .fail:
            return .resultRedBackground
        case .open:
            return .resultYellowBackground
        case .passed:
            return .resultGreenBackground
        }
    }

    var resultTitle: String {
        switch result.state {
        case .fail:
            return "certificate_check_validity_detail_view_result_not_valid_title".localized
        case .open:
            return "check_validity_no_rules_title".localized
        case .passed:
            return "certificate_check_validity_detail_view_result_valid_title".localized
        }
    }

    var resultSubtitle: String {
        var subtitle = String(format: "certificate_check_validity_detail_view_result_valid_message".localized, country.localized, DateUtils.displayDateTimeFormatter.string(from: date))
        if result.state == .open {
            subtitle = String(format: "%@\n\n%@", subtitle, "check_validity_no_rules_copy".localized)
        }
        if result.state == .passed {
            let acceptanceRules = result.result.filterAcceptanceRules
            let rulesCount = acceptanceRules.count
            let resultValidInfo = rulesCount == 1 ? "certificate_check_validity_detail_view_result_valid_info_singular".localized : "certificate_check_validity_detail_view_result_valid_info_plural".localized
            let ruleInfo = acceptanceRules.isEmpty ? "certificate_check_validity_detail_view_result_valid_info_no_rules".localized :
                String(format: resultValidInfo, rulesCount)
            return "\(subtitle)\n\n\(ruleInfo)"
        }
        return subtitle
    }

    private var dob: String {
        DateUtils.displayIsoDateOfBirth(dgc)
    }

    private func results(for result: CertLogic.Result, and pattern: String) -> [String] {
        self.result
            .result
            .filter { $0.result == result && $0.rule?.affectedString.contains(pattern) ?? false }
            .compactMap { res in
                if let localizedDescription = res.rule?.localizedDescription(for: Locale.current.languageCode) {
                    return localizedDescription
                }
                return res.rule?.description.first?.desc ?? nil
            }
    }

    var items: [(String, String, [String], [String])] {
        let exp = result.certificate.vaccinationCertificate.exp
        let expiryDate = exp != nil ? DateUtils.displayDateTimeFormatter.string(from: exp!) : ""

        if let r = dgc.r?.first {
            return [
                ("recovery_certificate_detail_view_data_name".localized, dgc.nam.fullNameReverse, [], []),
                ("recovery_certificate_detail_view_data_name_standard".localized, dgc.nam.fullNameTransliteratedReverse, [], []),
                ("recovery_certificate_detail_view_data_date_of_birth".localized, dob, results(for: .fail, and: "dob"), results(for: .open, and: "dob")),
                ("recovery_certificate_detail_view_data_disease".localized, r.tgDisplayName, results(for: .fail, and: "r.0.tg"), results(for: .open, and: "r.0.tg")),
                ("recovery_certificate_detail_view_data_date_first_positive_result".localized, DateUtils.isoDateFormatter.string(from: r.fr), results(for: .fail, and: "r.0.fr"), results(for: .open, and: "r.0.fr")),
                ("recovery_certificate_detail_view_data_country".localized, mapCountryNameIfGermany(r.co), results(for: .fail, and: "r.0.co"), results(for: .open, and: "r.0.co")),
                ("recovery_certificate_detail_view_data_issuer".localized, r.is, results(for: .fail, and: "r.0.is"), results(for: .open, and: "r.0.is")),
                ("recovery_certificate_detail_view_data_valid_from".localized, DateUtils.isoDateFormatter.string(from: r.df), results(for: .fail, and: "r.0.df"), results(for: .open, and: "r.0.df")),
                ("recovery_certificate_detail_view_data_valid_until".localized, DateUtils.isoDateFormatter.string(from: r.du), results(for: .fail, and: "r.0.du"), results(for: .open, and: "r.0.du")),
                ("recovery_certificate_detail_view_data_identifier".localized, r.ciDisplayName, results(for: .fail, and: "r.0.ci"), results(for: .open, and: "r.0.ci")),
                ("recovery_certificate_detail_view_data_expiry_date".localized,
                 String(format: "recovery_certificate_detail_view_data_expiry_date_message".localized, expiryDate) + "\n" +
                     "recovery_certificate_detail_view_data_expiry_date_note".localized,
                 [], [])
            ]
        }
        if let t = dgc.t?.first {
            return [
                ("test_certificate_detail_view_data_name".localized, dgc.nam.fullNameReverse, [], []),
                ("test_certificate_detail_view_data_name_standard".localized, dgc.nam.fullNameTransliteratedReverse, [], []),
                ("test_certificate_detail_view_data_date_of_birth".localized, dob, results(for: .fail, and: "dob"), results(for: .open, and: "dob")),
                ("test_certificate_detail_view_data_disease".localized, t.tgDisplayName, results(for: .fail, and: "t.0.tg"), results(for: .open, and: "t.0.tg")),
                ("test_certificate_detail_view_data_test_type".localized, t.ttDisplayName, results(for: .fail, and: "t.0.tt"), results(for: .open, and: "t.0.tt")),
                ("test_certificate_detail_view_data_test_name".localized, t.nm ?? "", results(for: .fail, and: "t.0.nm"), results(for: .open, and: "t.0.nm")),
                ("test_certificate_detail_view_data_test_manufactur".localized, t.maDisplayName ?? "", results(for: .fail, and: "t.0.ma"), results(for: .open, and: "t.0.ma")),
                ("test_certificate_detail_view_data_test_date_and_time".localized, DateUtils.displayIsoDateTimeFormatter.string(from: t.sc), results(for: .fail, and: "t.0.sc"), results(for: .open, and: "t.0.sc")),
                ("test_certificate_detail_view_data_test_results".localized, t.trDisplayName, results(for: .fail, and: "t.0.tr"), results(for: .open, and: "t.0.tr")),
                ("test_certificate_detail_view_data_test_centre".localized, t.tc ?? "", results(for: .fail, and: "t.0.tc"), results(for: .open, and: "t.0.tc")),
                ("test_certificate_detail_view_data_test_country".localized, mapCountryNameIfGermany(t.co), results(for: .fail, and: "t.0.co"), results(for: .open, and: "t.0.co")),
                ("test_certificate_detail_view_data_test_issuer".localized, t.is, results(for: .fail, and: "t.0.is"), results(for: .open, and: "t.0.is")),
                ("test_certificate_detail_view_data_test_identifier".localized, t.ciDisplayName, results(for: .fail, and: "t.0.ci"), results(for: .open, and: "t.0.ci")),
                ("test_certificate_detail_view_data_expiry_date".localized,
                 String(format: "test_certificate_detail_view_data_expiry_date_message".localized, expiryDate) + "\n" +
                     "test_certificate_detail_view_data_expiry_date_note".localized,
                 [], [])
            ]
        }
        if let v = dgc.v?.first {
            return [
                ("vaccination_certificate_detail_view_data_name".localized, dgc.nam.fullNameReverse, [], []),
                ("vaccination_certificate_detail_view_data_name_standard".localized, dgc.nam.fullNameTransliteratedReverse, [], []),
                ("vaccination_certificate_detail_view_data_date_of_birth".localized, dob, results(for: .fail, and: "dob"), results(for: .open, and: "dob")),
                ("vaccination_certificate_detail_view_data_disease".localized, v.tgDisplayName, results(for: .fail, and: "v.0.tg"), results(for: .open, and: "v.0.tg")),
                ("vaccination_certificate_detail_view_data_vaccine".localized, v.mpDisplayName, results(for: .fail, and: "v.0.mp"), results(for: .open, and: "v.0.mp")),
                ("vaccination_certificate_detail_view_data_vaccine_type".localized, v.vpDisplayName, results(for: .fail, and: "v.0.vp"), results(for: .open, and: "v.0.vp")),
                ("vaccination_certificate_detail_view_data_vaccine_manufactur".localized, v.maDisplayName, results(for: .fail, and: "v.0.ma"), results(for: .open, and: "v.0.ma")),
                ("vaccination_certificate_detail_view_data_vaccine_number".localized, "\(v.dn) / \(v.sd)", results(for: .fail, and: "v.0.sd"), results(for: .open, and: "v.0.sd")),
                ("vaccination_certificate_detail_view_data_vaccine_date_".localized, DateUtils.isoDateFormatter.string(from: v.dt), results(for: .fail, and: "v.0.dt"), results(for: .open, and: "v.0.dt")),
                ("vaccination_certificate_detail_view_data_vaccine_country".localized, mapCountryNameIfGermany(v.co), results(for: .fail, and: "v.0.co"), results(for: .open, and: "v.0.co")),
                ("vaccination_certificate_detail_view_data_vaccine_issuer".localized, v.is, results(for: .fail, and: "v.0.is"), results(for: .open, and: "v.0.is")),
                ("vaccination_certificate_detail_view_data_vaccine_identifier".localized, v.ciDisplayName, results(for: .fail, and: "v.0.ci"), results(for: .open, and: "v.0.ci")),
                ("vaccination_certificate_detail_view_data_expiry_date".localized,
                 String(format: "vaccination_certificate_detail_view_data_expiry_date_message".localized, expiryDate) + "\n" +
                     "vaccination_certificate_detail_view_data_expiry_date_note".localized,
                 [], [])
            ]
        }
        return []
    }

    private func mapCountryNameIfGermany(_ co: String) -> String {
        let countryName = co == "DE" ? "vaccination_certificate_detail_view_data_vaccine_country_germany" : co
        return countryName.localized
    }

    // MARK: - Lifecyle

    init(
        router: RuleCheckDetailRouterProtocol,
        resolvable: Resolver<Void>,
        result: CertificateResult,
        country: String,
        date: Date
    ) {
        self.router = router
        resolver = resolvable
        self.result = result
        self.country = country
        self.date = date
    }

    // MARK: - Methods

    func showQRCode() {
        router.showCertificate(for: result.certificate).cauterize()
    }

    func cancel() {
        resolver.cancel()
    }
}
