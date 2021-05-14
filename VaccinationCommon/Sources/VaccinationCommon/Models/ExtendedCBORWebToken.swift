//
//  ExtendedCBORWebToken.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
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
