//
//  VaccinationViewModel.swift
//  
//
//  Created by Timo Koenig on 23.04.21.
//

import Foundation
import VaccinationCommon

struct VaccinationViewModel {
    // MARK: - Properties

    private var token: CBORWebToken
    private var certificate: DigitalGreenCertificate { token.hcert.dgc }
    private var vaccination: Vaccination? { certificate.v.first }

    init(token: CBORWebToken) {
        self.token = token
    }

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
        vaccination?.mp ?? ""
    }

    var manufacturer: String {
        vaccination?.ma ?? ""
    }

    var vaccineCode: String {
        vaccination?.vp ?? ""
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
