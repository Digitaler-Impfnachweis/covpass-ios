//
//  Persistence+SelectStateOnboarding.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import Foundation

private enum Constants {
    static let selectStateOnboardingWasShown = "keyselectStateOnboardingWasShown"
}

public extension Persistence {
    var selectStateOnboardingWasShown: Bool {
        get {
            let value = try? fetch(Constants.selectStateOnboardingWasShown) as? Bool
            return value ?? false
        }
        set {
            try? store(Constants.selectStateOnboardingWasShown, value: newValue as Any)
        }
    }
}
