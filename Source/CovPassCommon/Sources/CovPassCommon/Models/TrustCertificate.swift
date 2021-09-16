//
//  TrustCertificate.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation

open class TrustCertificate: Codable {
    public var certificateType: String
    public var country: String
    public var kid: String
    public var rawData: String
    public var signature: String
    public var thumbprint: String
    public var timestamp: String

    public init(certificateType: String, country: String, kid: String, rawData: String, signature: String, thumbprint: String, timestamp: String) {
        self.certificateType = certificateType
        self.country = country
        self.kid = kid
        self.rawData = rawData
        self.signature = signature
        self.thumbprint = thumbprint
        self.timestamp = timestamp
    }

    open func loadPublicKey() throws -> SecKey {
        guard let certificateData = Data(base64Encoded: rawData),
              let cert = SecCertificateCreateWithData(nil, certificateData as CFData),
              let publicKey = SecCertificateCopyKey(cert)
        else {
            throw HCertError.publicKeyLoadError
        }
        return publicKey
    }
}
