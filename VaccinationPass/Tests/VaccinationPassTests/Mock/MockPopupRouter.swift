//
//  OnboardingRouter.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

import Foundation
import UIKit
import VaccinationUI


class MockPopupRouter: PopupRouter {
    // MARK: - Test Variables
    
    var presentPopupCalled = false
    
    // MARK: - PopupRouter
    
    func presentPopup(onTopOf viewController: UIViewController) {
        presentPopupCalled = true
    }
}
