//
//  File.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import PromiseKit

extension CBORWebToken {
    var noFraud: Promise<Self> {
        isFraud ? .init(error: CertificateError.invalidEntity) : .value(self)
    }

    var notExpired: Promise<Self> {
        guard let expirationDate = exp else {
            return .value(self)
        }
        return Date() > expirationDate ? .init(error: CertificateError.expiredCertifcate) : .value(self)
    }
}
