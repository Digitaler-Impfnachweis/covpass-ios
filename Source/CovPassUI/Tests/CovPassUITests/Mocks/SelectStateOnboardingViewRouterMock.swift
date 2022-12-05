//
//  SelectStateOnboardingViewRouterMock.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassUI
import Foundation
import PromiseKit
import XCTest

class SelectStateOnboardingViewRouterMock: SelectStateOnboardingViewRouterProtocol {
    var sceneCoordinator: SceneCoordinator = SceneCoordinatorMock()
    let showFederalStateSelectionExpectation = XCTestExpectation()
    let showFAQExpectation = XCTestExpectation()

    func showFederalStateSelection() -> Promise<Void> {
        showFederalStateSelectionExpectation.fulfill()
        return .value
    }

    func showFAQ() {
        showFAQExpectation.fulfill()
    }
}
