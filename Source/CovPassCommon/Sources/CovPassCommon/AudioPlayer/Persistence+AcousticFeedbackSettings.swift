//
//  Persistence+AcousticFeedbackSettings.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

private let keyEnableAcousticFeedback = "keyEnableAcousticFeedback"

public extension Persistence {
    var enableAcousticFeedback: Bool {
        get {
            let value = try? fetch(keyEnableAcousticFeedback) as? Bool
            return value ?? false
        }
        set {
            try? store(keyEnableAcousticFeedback, value: newValue as Any)
        }
    }
}
