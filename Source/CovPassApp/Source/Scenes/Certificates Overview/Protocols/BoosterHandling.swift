//
//  BoosterHandling.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import CovPassCommon
import CertLogic

struct BoosterCandidate {
    let token: ExtendedCBORWebToken
    let rules: [ValidationResult]
}

// MARK: - Booster handling
protocol BoosterHandling {

    /// Check check!
    func checkForVaccinationBooster(completion: (_ result: [BoosterCandidate]) -> Void)

    /// Marks the given certificates as 'has notification'
    ///
    /// - Parameter certificates: tuple of certificates and notification states. If an empty list is given, all existing states are reset/removed.
    func updateBoosterNotificationState(for certificates: [(BoosterCandidate, NotificationState)])

    /// Display a notification about newly availanble boosters
    func showBoosterNotification()
}
