//
//  ExtendedCBORWebToken+Notification.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import CovPassCommon

protocol Notifiable {
    var hasNotifications: Bool { get set }
}

extension ExtendedCBORWebToken: Notifiable {
    private static let suite = "NotificationSettings"

    var hasNotifications: Bool {
        get {
            UserDefaults(suiteName: Self.suite)?.bool(forKey: identifier) ?? false
        }
        set {
            if newValue {
                UserDefaults(suiteName: Self.suite)?.setValue(newValue, forKey: identifier)
            } else {
                UserDefaults(suiteName: Self.suite)?.removeObject(forKey: identifier)
            }
        }
    }

    /// Certificate identifier as a hashed combination of name and date of birth
    private var identifier: String {
        let name = vaccinationCertificate.hcert.dgc.nam.fullNameTransliterated
        let dob = vaccinationCertificate.hcert.dgc.dobString ?? ""
        return CustomHasher.sha256("\(name)\(dob)")
    }
}
