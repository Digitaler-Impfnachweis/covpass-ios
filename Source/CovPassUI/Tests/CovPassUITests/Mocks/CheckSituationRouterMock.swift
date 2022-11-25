//
//  CheckSituationRouterMock.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassUI
import Foundation
import PromiseKit
import XCTest

class CheckSituationRouterMock: CheckSituationRouterProtocol {
    var sceneCoordinator: SceneCoordinator = SceneCoordinatorMock()
    var noInternetExpecation = XCTestExpectation()
    var disableOfflineRevocation = false

    func showNoInternetErrorDialog(_: Error) {
        noInternetExpecation.fulfill()
    }

    func showOfflineRevocationDisableConfirmation() -> Guarantee<Bool> {
        .value(disableOfflineRevocation)
    }
}
