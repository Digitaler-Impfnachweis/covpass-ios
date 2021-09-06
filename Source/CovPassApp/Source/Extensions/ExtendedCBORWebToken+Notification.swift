//
//  ExtendedCBORWebToken+Notification.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import CovPassCommon

protocol Notifiable {
    var notificationState: NotificationState { get set }

    /// The optional rule identifier that triggered the notification
    var notificationRuleID: String? { get set } // quick hack & a refactoring candidate!
}

enum NotificationState: Int {
    /// No notification
    case none
    /// Notification already shown but somewhat present
    case existing
    /// New notification
    case new
}

extension ExtendedCBORWebToken: Notifiable {
    private static let suite = "NotificationSettings"

    var notificationState: NotificationState {
        get {
            let existing = UserDefaults(suiteName: Self.suite)?.integer(forKey: keyState) ?? NotificationState.none.rawValue
            return NotificationState(rawValue: existing) ?? .none
        }
        set {
            if newValue.rawValue == NotificationState.none.rawValue {
                UserDefaults(suiteName: Self.suite)?.removeObject(forKey: keyState)
            } else {
                UserDefaults(suiteName: Self.suite)?.setValue(newValue.rawValue, forKey: identifier)
            }
        }
    }

    var notificationRuleID: String? {
        get {
            UserDefaults(suiteName: Self.suite)?.string(forKey: keyRule)
        }
        set {
            UserDefaults(suiteName: Self.suite)?.setValue(newValue, forKey: keyRule)
        }
    }

    static func resetNotificationStates() {
        UserDefaults.standard.removePersistentDomain(forName: Self.suite)
    }

    #if DEBUG
    static func printNotificationStates() {
        guard let defaults = UserDefaults(suiteName: Self.suite) else { return }
        dump(defaults.dictionaryRepresentation())
    }
    #endif

    // MARK: - Identifiers & Keys

    /// Certificate identifier as a hashed combination of name and date of birth.
    ///
    /// Currently only used here, so `private`.
    private var identifier: String {
        let name = vaccinationCertificate.hcert.dgc.nam.fullNameTransliterated
        let dob = vaccinationCertificate.hcert.dgc.dobString ?? ""
        return CustomHasher.sha256("\(name)\(dob)")
    }

    private var keyState: String { "\(identifier)_state" }
    private var keyRule: String { "\(identifier)_rule" }
}
