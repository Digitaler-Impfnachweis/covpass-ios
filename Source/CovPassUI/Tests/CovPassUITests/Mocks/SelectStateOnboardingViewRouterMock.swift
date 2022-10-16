//
//  SelectStateOnboardingViewRouterMock.swift
//  
//
//  Created by Fatih Karakurt on 14.10.22.
//

import Foundation
import PromiseKit
import XCTest
import CovPassUI

class SelectStateOnboardingViewRouterMock: SelectStateOnboardingViewRouterProtocol {
    
    var sceneCoordinator: SceneCoordinator = SceneCoordinatorMock()
    let showFederalStateSelectionExpectation = XCTestExpectation()

    func showFederalStateSelection() -> Promise<Void> {
        showFederalStateSelectionExpectation.fulfill()
        return .value
    }
}
