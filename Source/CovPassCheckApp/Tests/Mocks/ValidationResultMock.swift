//
//  ValidationResultMock.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassUI
import PromiseKit
import XCTest

struct ValidationResultRouterMock: ValidationResultRouterProtocol {
    
    var showRevocationExpectation = XCTestExpectation()
    var sceneCoordinator: SceneCoordinator = SceneCoordinatorMock()

    func showStart() {}

    func scanQRCode() -> Promise<ScanResult> {
        .value(.success(""))
    }
    
    func showRevocation() {
        showRevocationExpectation.fulfill()
    }

}
