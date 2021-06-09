//
//  VaccinationViewModel.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import CovPassUI
import Foundation
import PromiseKit

struct VaccinationViewModel {
    // MARK: - Properties

    private let vaccination: Vaccination

    var headline: String {
        let number = vaccination.dn
        let total = vaccination.sd
        return String(format: "vaccination_certificate_detail_view_vaccination_title".localized, number, total)
    }

    var date: String {
        DateUtils.displayDateFormatter.string(from: vaccination.dt)
    }

    var vaccine: String {
        vaccination.map(key: vaccination.mp, from: Bundle.commonBundle.url(forResource: "vaccine-medicinal-product", withExtension: "json")) ?? vaccination.mp
    }

    var manufacturer: String {
        vaccination.map(key: vaccination.ma, from: Bundle.commonBundle.url(forResource: "vaccine-mah-manf", withExtension: "json")) ?? vaccination.ma
    }

    var vaccineCode: String {
        vaccination.map(key: vaccination.vp, from: Bundle.commonBundle.url(forResource: "vaccine-prophylaxis", withExtension: "json")) ?? vaccination.vp
    }

    var fullVaccineProduct: String {
        "\(vaccineCode) (\(vaccine))"
    }

    var issuer: String {
        vaccination.is
    }

    var country: String {
        vaccination.map(key: vaccination.co, from: Bundle.commonBundle.url(forResource: "country", withExtension: "json")) ?? vaccination.co
    }

    var uvci: String {
        vaccination.ci.strip(prefix: "URN:UVCI:")
    }

    // MARK: - Lifecycle

    init(
        vaccination: Vaccination
    ) {
        self.vaccination = vaccination
    }

    func delete() {
        delegate?.vaccinationViewDidPressDelete(vaccination)
    }

    func showCertificate() {
        delegate?.vaccinationViewDidPressShowQRCode(vaccination)
    }
}
