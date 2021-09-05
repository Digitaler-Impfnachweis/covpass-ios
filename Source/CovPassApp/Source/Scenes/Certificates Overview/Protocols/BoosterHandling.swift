//
//  BoosterHandling.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import CovPassCommon

// MARK: - Booster handling
protocol BoosterHandling {

    /// Check check!
    func checkForVaccinationBooster(completion: (_ result: [ExtendedCBORWebToken]) -> Void)

    /// Marks the given certificates as 'has notification'
    ///
    /// - Parameter certificates: tuple of certificates and notification states. If an empty list is given, all existing states are reset/removed.
    func updateBoosterNotificationState(for certificates: [(ExtendedCBORWebToken, NotificationState)])

    /// Display a notification about newly availanble boosters
    func showBoosterNotification()
}
