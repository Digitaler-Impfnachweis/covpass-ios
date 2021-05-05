//
//  OnboardingRouterProtocol.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

import UIKit

public protocol OnboardingRouterProtocol: RouterProtocol {
    func showNextScene()
    func showPreviousScene()
}
