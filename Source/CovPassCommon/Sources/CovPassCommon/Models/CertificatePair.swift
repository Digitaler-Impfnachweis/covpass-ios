//
//  CertificatePair.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation

public struct CertificatePair {
    public var certificates: [ExtendedCBORWebToken]
    public var isFavorite: Bool
    public init(certificates: [ExtendedCBORWebToken], isFavorite: Bool = false) {
        self.certificates = certificates
        self.isFavorite = isFavorite
    }
}
