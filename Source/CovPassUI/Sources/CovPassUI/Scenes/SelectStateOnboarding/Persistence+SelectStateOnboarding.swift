//
//  Persistence+SelectStateOnboarding.swift
//  
//
//  Created by Fatih Karakurt on 14.10.22.
//

import Foundation
import CovPassCommon

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
