//
//  VaccinationViewModel.swift
//  
//
//  Created by Timo Koenig on 23.04.21.
//

import Foundation
import VaccinationCommon

public struct VaccinationViewModel {

    private var certificate: VaccinationCertificate

    public init(certificate: VaccinationCertificate) {
        self.certificate = certificate
    }

    public var headline: String {
        let number = String(certificate.vaccination.first?.seriesNumber ?? 0)
        let total = String(certificate.vaccination.first?.seriesTotal ?? 0)
        return String(format: "vaccination_detail_vaccination_title".localized, number, total)
    }

    public var date: String {
        guard let occurrence = certificate.vaccination.first?.occurrence else { return "" }
        return DateUtils.displayDateFormatter.string(from: occurrence)
    }

    public var vaccine: String {
        return certificate.vaccination.first?.product ?? ""
    }

    public var manufacturer: String {
        return certificate.vaccination.first?.manufacturer ?? ""
    }

    public var vaccineCode: String {
        return certificate.vaccination.first?.vaccineCode ?? ""
    }

    public var location: String {
        return certificate.vaccination.first?.location ?? ""
    }

    public var issuer: String {
        return certificate.issuer
    }

    public var country: String {
        return certificate.vaccination.first?.country ?? ""
    }

    public var uvci: String {
        return certificate.id
    }
}
