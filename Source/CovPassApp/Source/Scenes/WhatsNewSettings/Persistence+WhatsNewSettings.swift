//
//  Persistence+WhatsNewSettings.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon

private let keyWhatsNew = "keyWhatsNew"

extension Persistence {
    var disableWhatsNew: Bool {
        get {
            let value = try? fetch(keyWhatsNew) as? Bool
            return value ?? false
        }
        set {
            try? store(keyWhatsNew, value: newValue as Any)
        }
    }
}
