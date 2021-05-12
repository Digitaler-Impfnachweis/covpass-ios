//
//  VaccinationViewModel.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

import Foundation
import VaccinationCommon

struct VaccinationViewModel {
    // MARK: - Properties

    private var token: CBORWebToken
    private var certificate: DigitalGreenCertificate { token.hcert.dgc }
    private var vaccination: Vaccination? { certificate.v.first }

    var headline: String {
        let number = vaccination?.dn ?? 0
        let total = vaccination?.sd ?? 0
        return String(format: "vaccination_certificate_detail_view_vaccination_title".localized, number, total)
    }

    var date: String {
        guard let occurrence = vaccination?.dt else { return "" }
        return DateUtils.displayDateFormatter.string(from: occurrence)
    }

    var vaccine: String {
        vaccination?.map(key: vaccination?.mp, from: Bundle.commonBundle.url(forResource: XCConfiguration.value(String.self, forKey: "VACCINE_MEDICINAL_PRODUCT"), withExtension: "json")) ?? vaccination?.mp ?? ""
    }

    var manufacturer: String {
        vaccination?.map(key: vaccination?.ma, from: Bundle.commonBundle.url(forResource: XCConfiguration.value(String.self, forKey: "VACCINE_MANUFACTURER"), withExtension: "json")) ?? vaccination?.ma ?? ""
    }

    var vaccineCode: String {
        vaccination?.map(key: vaccination?.vp, from: Bundle.commonBundle.url(forResource: XCConfiguration.value(String.self, forKey: "VACCINE_PROPHYLAXIS"), withExtension: "json")) ?? vaccination?.vp ?? ""
    }

    var issuer: String {
        token.iss
    }

    var country: String {
        vaccination?.co ?? ""
    }

    var uvci: String {
        vaccination?.ci ?? ""
    }

    // MARK: - Lifecycle

    init(token: CBORWebToken) {
        self.token = token
    }
}
