//
//  RuleCheckDetailViewModel.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import CovPassUI
import PromiseKit
import UIKit
import CertLogic

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
            return "certificate_check_validity_detail_view_result_not_testable_title".localized
        case .passed:
            return "certificate_check_validity_detail_view_result_valid_title".localized
        }
    }

    var resultSubtitle: String {
        var subtitle = String(format: "certificate_check_validity_detail_view_result_valid_message".localized, country.localized, DateUtils.displayDateTimeFormatter.string(from: date))
        if result.state == .open {
            subtitle = String(format: "%@\n\n%@", subtitle, "certificate_check_validity_detail_view_result_not_testable_second_message".localized)
        }
        let ruleInfo = result.result.isEmpty ? "certificate_check_validity_detail_view_result_valid_info_no_rules".localized : String(format: "certificate_check_validity_detail_view_result_valid_info".localized, result.result.count)
        return "\(subtitle)\n\n\(ruleInfo)"
    }

    var infoText1: String {
        if dgc.t?.isEmpty == false {
            return "certificate_check_validity_detail_view_test_result_note_de".localized
        }
        if dgc.r?.isEmpty == false {
            return "certificate_check_validity_detail_view_recovery_result_note_de".localized
        }
        return "certificate_check_validity_detail_view_vaccination_result_note_de".localized
    }

    var infoText2: String {
        if dgc.t?.isEmpty == false {
            return "certificate_check_validity_detail_view_test_result_note_en".localized
        }
        if dgc.r?.isEmpty == false {
            return "certificate_check_validity_detail_view_recovery_result_note_en".localized
        }
        return "certificate_check_validity_detail_view_vaccination_result_note_en".localized
    }

    private var dob: String {
        return DateUtils.displayDateOfBirth(dgc)
    }

    private func results(for result: CertLogic.Result, and pattern: String) -> [String] {
        self.result
            .result
            .filter { $0.result == result && $0.rule?.affectedString.contains(pattern) ?? false }
            .compactMap { res in
                if let trans = res.rule?.description.first(where: { $0.lang.lowercased() == "de" }) {
                    return trans.desc
                }
                if let trans = res.rule?.description.first(where: { $0.lang.lowercased() == "en" }) {
                    return trans.desc
                }
                return nil
            }
    }

    var items: [(String, String, [String], [String])] {
        if let r = dgc.r?.first {
            return [
                ("recovery_certificate_detail_view_data_name".localized, dgc.nam.fullNameReverse, [], []),
                ("recovery_certificate_detail_view_data_date_of_birth".localized, dob, results(for: .fail, and: "dob"), results(for: .open, and: "dob")),
                ("recovery_certificate_detail_view_data_disease".localized, r.map(key: r.tg, from: Bundle.commonBundle.url(forResource: "disease-agent-targeted", withExtension: "json")) ?? r.tg, results(for: .fail, and: "r.0.tg"), results(for: .open, and: "r.0.tg")),
                ("recovery_certificate_detail_view_data_date_first_positive_result".localized, DateUtils.isoDateFormatter.string(from: r.fr), results(for: .fail, and: "r.0.fr"), results(for: .open, and: "r.0.fr")),
                ("recovery_certificate_detail_view_data_country".localized, r.co, results(for: .fail, and: "r.0.co"), results(for: .open, and: "r.0.co")),
                ("recovery_certificate_detail_view_data_issuer".localized, r.is, results(for: .fail, and: "r.0.is"), results(for: .open, and: "r.0.is")),
                ("recovery_certificate_detail_view_data_valid_from".localized, DateUtils.isoDateFormatter.string(from: r.df), results(for: .fail, and: "r.0.df"), results(for: .open, and: "r.0.df")),
                ("recovery_certificate_detail_view_data_valid_until".localized, DateUtils.isoDateFormatter.string(from: r.du), results(for: .fail, and: "r.0.du"), results(for: .open, and: "r.0.du")),
                ("recovery_certificate_detail_view_data_identifier".localized, r.ci, results(for: .fail, and: "r.0.ci"), results(for: .open, and: "r.0.ci"))
            ]
        }
        if let t = dgc.t?.first {
            return [
                ("test_certificate_detail_view_data_name".localized, dgc.nam.fullNameReverse, [], []),
                ("test_certificate_detail_view_data_date_of_birth".localized, dob, results(for: .fail, and: "dob"), results(for: .open, and: "dob")),
                ("test_certificate_detail_view_data_disease".localized, t.map(key: t.tg, from: Bundle.commonBundle.url(forResource: "disease-agent-targeted", withExtension: "json")) ?? t.tg, results(for: .fail, and: "t.0.tg"), results(for: .open, and: "t.0.tg")),
                ("test_certificate_detail_view_data_test_type".localized, t.map(key: t.tt, from: Bundle.commonBundle.url(forResource: "test-type", withExtension: "json")) ?? t.tt, results(for: .fail, and: "t.0.tt"), results(for: .open, and: "t.0.tt")),
                ("test_certificate_detail_view_data_test_name".localized, t.nm ?? "", results(for: .fail, and: "t.0.nm"), results(for: .open, and: "t.0.nm")),
                ("test_certificate_detail_view_data_test_manufactur".localized, t.map(key: t.ma, from: Bundle.commonBundle.url(forResource: "test-manf", withExtension: "json")) ?? t.ma ?? "", results(for: .fail, and: "t.0.ma"), results(for: .open, and: "t.0.ma")),
                ("test_certificate_detail_view_data_test_date_and_time".localized, DateUtils.displayIsoDateTimeFormatter.string(from: t.sc), results(for: .fail, and: "t.0.sc"), results(for: .open, and: "t.0.sc")),
                ("test_certificate_detail_view_data_test_results".localized, t.map(key: t.tr, from: Bundle.commonBundle.url(forResource: "test-result", withExtension: "json")) ?? t.tr, results(for: .fail, and: "t.0.tr"), results(for: .open, and: "t.0.tr")),
                ("test_certificate_detail_view_data_test_centre".localized, t.tc, results(for: .fail, and: "t.0.tc"), results(for: .open, and: "t.0.tc")),
                ("test_certificate_detail_view_data_test_country".localized, t.co, results(for: .fail, and: "t.0.co"), results(for: .open, and: "t.0.co")),
                ("test_certificate_detail_view_data_test_issuer".localized, t.is, results(for: .fail, and: "t.0.is"), results(for: .open, and: "t.0.is")),
                ("test_certificate_detail_view_data_test_identifier".localized, t.ci, results(for: .fail, and: "t.0.ci"), results(for: .open, and: "t.0.ci"))
            ]
        }
        if let v = dgc.v?.first {
            return [
                ("vaccination_certificate_detail_view_data_name".localized, dgc.nam.fullNameReverse, [], []),
                ("vaccination_certificate_detail_view_data_date_of_birth".localized, dob, results(for: .fail, and: "dob"), results(for: .open, and: "dob")),
                ("vaccination_certificate_detail_view_data_disease".localized, v.map(key: v.tg, from: Bundle.commonBundle.url(forResource: "disease-agent-targeted", withExtension: "json")) ?? v.tg, results(for: .fail, and: "v.0.tg"), results(for: .open, and: "v.0.tg")),
                ("vaccination_certificate_detail_view_data_vaccine".localized, v.map(key: v.mp, from: Bundle.commonBundle.url(forResource: "vaccine-medicinal-product", withExtension: "json")) ?? v.mp, results(for: .fail, and: "v.0.mp"), results(for: .open, and: "v.0.mp")),
                ("vaccination_certificate_detail_view_data_vaccine_type".localized, v.map(key: v.vp, from: Bundle.commonBundle.url(forResource: "vaccine-prophylaxis", withExtension: "json")) ?? v.vp, results(for: .fail, and: "v.0.vp"), results(for: .open, and: "v.0.vp")),
                ("vaccination_certificate_detail_view_data_vaccine_manufactur".localized, v.map(key: v.ma, from: Bundle.commonBundle.url(forResource: "vaccine-mah-manf", withExtension: "json")) ?? v.ma, results(for: .fail, and: "v.0.ma"), results(for: .open, and: "v.0.ma")),
                ("vaccination_certificate_detail_view_data_vaccine_number".localized, "\(v.dn) / \(v.sd)", results(for: .fail, and: "v.0.sd"), results(for: .open, and: "v.0.sd")),
                ("vaccination_certificate_detail_view_data_vaccine_date_".localized, DateUtils.isoDateFormatter.string(from: v.dt), results(for: .fail, and: "v.0.dt"), results(for: .open, and: "v.0.dt")),
                ("vaccination_certificate_detail_view_data_vaccine_country".localized, v.map(key: v.co, from: Bundle.commonBundle.url(forResource: "country", withExtension: "json")) ?? v.co, results(for: .fail, and: "v.0.co"), results(for: .open, and: "v.0.co")),
                ("vaccination_certificate_detail_view_data_vaccine_issuer".localized, v.is, results(for: .fail, and: "v.0.is"), results(for: .open, and: "v.0.is")),
                ("vaccination_certificate_detail_view_data_vaccine_identifier".localized, v.ci, results(for: .fail, and: "v.0.ci"), results(for: .open, and: "v.0.ci"))
            ]
        }
        return []
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
