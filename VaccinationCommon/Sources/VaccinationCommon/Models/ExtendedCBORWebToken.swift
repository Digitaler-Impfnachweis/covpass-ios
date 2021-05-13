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

    public init(vaccinationCertificate: CBORWebToken, vaccinationQRCodeData: String) {
        self.vaccinationCertificate = vaccinationCertificate
        self.vaccinationQRCodeData = vaccinationQRCodeData
    }
}

extension ExtendedCBORWebToken: Equatable {
    public static func == (lhs: ExtendedCBORWebToken, rhs: ExtendedCBORWebToken) -> Bool {
        return lhs.vaccinationQRCodeData == rhs.vaccinationQRCodeData
    }
}
