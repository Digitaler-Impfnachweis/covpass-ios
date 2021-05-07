//
//  VaccinationViewModel.swift
//  
//
//  Created by Timo Koenig on 23.04.21.
//

import Foundation
import VaccinationCommon

public struct VaccinationViewModel {

    private var token: CBORWebToken
    private var certificate: DigitalGreenCertificate { token.hcert.dgc }
    private var vaccination: Vaccination? { certificate.v.first }

    public init(token: CBORWebToken) {
        self.token = token
    }

    public var headline: String {
        let number = vaccination?.dn ?? 0
        let total = vaccination?.sd ?? 0
        return String(format: "vaccination_certificate_detail_view_vaccination_title".localized, number, total)
    }

    public var date: String {
        guard let occurrence = vaccination?.dt else { return "" }
        return DateUtils.displayDateFormatter.string(from: occurrence)
    }

    public var vaccine: String {
        vaccination?.mp ?? ""
    }

    public var manufacturer: String {
        vaccination?.ma ?? ""
    }

    public var vaccineCode: String {
        vaccination?.vp ?? ""
    }

    public var issuer: String {
        token.iss
    }

    public var country: String {
        vaccination?.co ?? ""
    }

    public var uvci: String {
        vaccination?.ci ?? ""
    }
}
