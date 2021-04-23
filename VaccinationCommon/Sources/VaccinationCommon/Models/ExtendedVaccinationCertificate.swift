//
//  ExtendedVaccinationCertificate.swift
//  
//
//  Copyright © 2021 IBM. All rights reserved.
//

import Foundation

public struct ExtendedVaccinationCertificate: Codable {
    /// The vaccination certificate
    public var vaccinationCertificate: VaccinationCertificate

    /// The raw qr code data of the vaccination certificate
    public var vaccinationQRCodeData: String

    /// The raw qr code data of the validation certificate
    public var validationQRCodeData: String?

    public init(vaccinationCertificate: VaccinationCertificate, vaccinationQRCodeData: String, validationQRCodeData: String?) {
        self.vaccinationCertificate = vaccinationCertificate
        self.vaccinationQRCodeData = vaccinationQRCodeData
        self.validationQRCodeData = validationQRCodeData
    }
}
