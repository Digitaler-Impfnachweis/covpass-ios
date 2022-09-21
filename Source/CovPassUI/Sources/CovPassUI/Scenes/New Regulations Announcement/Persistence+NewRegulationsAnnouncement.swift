//
//  Persistence+NewRegulationsAnnouncement.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon

private enum Constants {
    static let newRegulationsOnboardingScreenWasShown = "keyNewRegulationsOnboardingScreenWasShown"
}

public extension Persistence {
    var newRegulationsOnboardingScreenWasShown: Bool {
        get {
            let value = try? fetch(Constants.newRegulationsOnboardingScreenWasShown) as? Bool
            return value ?? false
        }
        set {
            try? store(Constants.newRegulationsOnboardingScreenWasShown, value: newValue as Any)
        }
    }
}
