//
//  ExtendedCBORWebToken.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation

public struct ExtendedCBORWebToken: Codable, QRCodeScanable {
    /// CBOR web token vaccination certificate
    public var vaccinationCertificate: CBORWebToken

    /// Raw QRCode data of the cbor web token vaccination certificate
    public var vaccinationQRCodeData: String

    public var wasExpiryAlertShown: Bool?

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

extension ExtendedCBORWebToken: Comparable {
    /// Sort by dose number of first vaccination, result date of first test or valid until date of first recovery
    public static func < (lhs: ExtendedCBORWebToken, rhs: ExtendedCBORWebToken) -> Bool {
        lhs.vaccinationCertificate.hcert.dgc.v?.first?.dn ?? 0 > rhs.vaccinationCertificate.hcert.dgc.v?.first?.dn ?? 0 ||
            lhs.vaccinationCertificate.hcert.dgc.t?.first?.sc ?? Date() > rhs.vaccinationCertificate.hcert.dgc.t?.first?.sc ?? Date() ||
            lhs.vaccinationCertificate.hcert.dgc.r?.first?.du ?? Date() > rhs.vaccinationCertificate.hcert.dgc.r?.first?.du ?? Date()
    }
}
