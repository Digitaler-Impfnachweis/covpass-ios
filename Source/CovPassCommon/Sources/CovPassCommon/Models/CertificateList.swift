//
//  CertificateList.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation

public struct CertificateList: Codable {
    public var certificates: [ExtendedCBORWebToken]
    public var favoriteCertificateId: String?
    public var certificatePairs: [CertificatePair] {
        certificates
            .partitionedByOwner
            .map { extendedCBORWebTokens in
                let uvcis = extendedCBORWebTokens.map(\.vaccinationCertificate.hcert.dgc.uvci)
                let isFavorite = uvcis.contains { $0 == favoriteCertificateId }
                return .init(certificates: extendedCBORWebTokens, isFavorite: isFavorite)
            }
    }
    public var numberOfPersons: Int {
        certificatePairs.count
    }

    enum CodingKeys: String, CodingKey {
        case certificates
        case favoriteCertificateId
    }

    public init(certificates: [ExtendedCBORWebToken], favoriteCertificateId: String? = nil) {
        self.certificates = certificates
        self.favoriteCertificateId = favoriteCertificateId
    }
}
