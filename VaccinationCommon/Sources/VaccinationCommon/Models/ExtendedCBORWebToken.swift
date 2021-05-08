//
//  ExtendedCBORWebToken.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

import Foundation

public struct ExtendedCBORWebToken: Codable {
    /// CBOR web token vaccination certificate
    public var vaccinationCertificate: CBORWebToken

    /// Raw QRCode data of the cbor web token vaccination certificate
    public var vaccinationQRCodeData: String

    /// Raw QRCode data of the cbor web token validation certificate
    public var validationQRCodeData: String?

    public init(vaccinationCertificate: CBORWebToken, vaccinationQRCodeData: String, validationQRCodeData: String? = nil) {
        self.vaccinationCertificate = vaccinationCertificate
        self.vaccinationQRCodeData = vaccinationQRCodeData
        self.validationQRCodeData = validationQRCodeData
    }
}

extension ExtendedCBORWebToken: Equatable {
    public static func == (lhs: ExtendedCBORWebToken, rhs: ExtendedCBORWebToken) -> Bool {
        return lhs.vaccinationQRCodeData == rhs.vaccinationQRCodeData
    }
}
