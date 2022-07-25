//
//  Persistence+CertificateRevocationService.swift
//  
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation

private let keyCertificateRevocationServiceLastUpdate = "keyCertificateRevocationServiceLastUpdate"

public extension Persistence {
    var certificateRevocationServiceLastUpdate: Date? {
        get {
            let value = try? fetch(keyCertificateRevocationServiceLastUpdate) as? Date
            return value
        }
        set {
            try? store(
                keyCertificateRevocationServiceLastUpdate,
                value: newValue as Any
            )
        }
    }
}
