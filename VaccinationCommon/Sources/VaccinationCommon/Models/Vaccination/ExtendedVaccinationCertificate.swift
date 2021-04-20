//
//  ExtendedVaccinationCertificate.swift
//  
//
//  Copyright © 2021 IBM. All rights reserved.
//

import Foundation

public struct ExtendedVaccinationCertificate {
    /// The vaccination certificate
    var vaccinationCertificate: VaccinationCertificate

    /// The raw qr content of the full vaccination certificate. This is not really used right now, but stored as a
    /// safety fallback in case of e.g. data migration issues.
    var vaccinationQRContent: String

    /// The raw qr content of the simplified validation certificate.
    var validationQRContent: String?

    public init(vaccinationCertificate: VaccinationCertificate, vaccinationQRContent: String, validationQRContent: String?) {
        self.vaccinationCertificate = vaccinationCertificate
        self.vaccinationQRContent = vaccinationQRContent
        self.validationQRContent = validationQRContent
    }
}
