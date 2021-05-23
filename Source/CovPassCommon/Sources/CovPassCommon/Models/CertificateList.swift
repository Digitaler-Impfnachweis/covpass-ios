//
//  VaccinationCertificateList.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation

public struct VaccinationCertificateList: Codable {
    public var certificates: [ExtendedCBORWebToken]
    public var favoriteCertificateId: String?

    public init(certificates: [ExtendedCBORWebToken], favoriteCertificateId: String? = nil) {
        self.certificates = certificates
        self.favoriteCertificateId = favoriteCertificateId
    }

    public func isFavoriteCertificate(_ certificate: ExtendedCBORWebToken) -> Bool {
        guard let id = favoriteCertificateId else {
            return false
        }
        return certificates
            .certificatePair(for: certificate)
            .containsCertificateWithId(id)
    }
}
