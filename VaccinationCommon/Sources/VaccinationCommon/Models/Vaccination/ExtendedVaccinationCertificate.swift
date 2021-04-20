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

    /// The raw qr code data of the vaccination certificate
    var vaccinationQRCodeData: String

    /// The validation certificate
    var validationCertificate: ValidationCertificate?

    /// The raw qr code data of the validation certificate
    var validationQRCodeData: String?

    public init(vaccinationCertificate: VaccinationCertificate, vaccinationQRCodeData: String, validationCertificate: ValidationCertificate?, validationQRCodeData: String?) {
        self.vaccinationCertificate = vaccinationCertificate
        self.vaccinationQRCodeData = vaccinationQRCodeData
        self.validationCertificate = validationCertificate
        self.validationQRCodeData = validationQRCodeData
    }
}
