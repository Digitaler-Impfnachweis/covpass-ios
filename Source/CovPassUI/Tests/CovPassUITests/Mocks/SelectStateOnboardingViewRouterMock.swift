//
//  SelectStateOnboardingViewRouterMock.swift
//
//
//  Created by Fatih Karakurt on 14.10.22.
//

import CovPassUI
import Foundation
import PromiseKit
import XCTest

class SelectStateOnboardingViewRouterMock: SelectStateOnboardingViewRouterProtocol {
    var sceneCoordinator: SceneCoordinator = SceneCoordinatorMock()
    let showFederalStateSelectionExpectation = XCTestExpectation()

    func showFederalStateSelection() -> Promise<Void> {
        showFederalStateSelectionExpectation.fulfill()
        return .value
    }
}
