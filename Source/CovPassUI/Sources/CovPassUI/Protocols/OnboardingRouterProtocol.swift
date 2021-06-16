//
//  OnboardingRouterProtocol.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

public protocol OnboardingRouterProtocol: RouterProtocol {
    func showNextScene()
    func showPreviousScene()
    func showDataPrivacyScene()
}
