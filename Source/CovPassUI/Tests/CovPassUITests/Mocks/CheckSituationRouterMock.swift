//
//  CheckSituationRouterMock.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import PromiseKit
import XCTest
import CovPassUI

class CheckSituationRouterMock: CheckSituationRouterProtocol {
    
    var sceneCoordinator: SceneCoordinator = SceneCoordinatorMock()
    var noInternetExpecation = XCTestExpectation()
    var disableOfflineRevocation = false
    
    func showNoInternetErrorDialog(_ error: Error) {
        noInternetExpecation.fulfill()
    }

    func showOfflineRevocationDisableConfirmation() -> Guarantee<Bool> {
        return .value(disableOfflineRevocation)
    }
}
