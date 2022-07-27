//
//  Persistence+CertificateRevocationService.swift
//  
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation

private let keyCertificateRevocationOfflineServiceLastUpdate = "keyCertificateRevocationOfflineServiceLastUpdate"
private let keyIsCertificateRevocationOfflineServiceEnabled = "keyIsCertificateRevocationOfflineServiceEnabled"

public extension Persistence {
    var certificateRevocationOfflineServiceLastUpdate: Date? {
        get {
            let value = try? fetch(keyCertificateRevocationOfflineServiceLastUpdate) as? Date
            return value
        }
        set {
            if newValue != nil {
                try? store(
                    keyCertificateRevocationOfflineServiceLastUpdate,
                    value: newValue as Any
                )
            } else {
                try? delete(keyCertificateRevocationOfflineServiceLastUpdate)
            }
        }
    }

    var isCertificateRevocationOfflineServiceEnabled: Bool {
        get {
            let value = try? fetch(keyIsCertificateRevocationOfflineServiceEnabled) as? Bool
            return value ?? false
        }
        set {
            try? store(
                keyIsCertificateRevocationOfflineServiceEnabled,
                value: newValue as Bool
            )
        }
    }
}
