//
//  ValidationResultMock.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
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
    
    func showRevocation(token: ExtendedCBORWebToken, keyFilename: String) -> Promise<Void> {
        showRevocationExpectation.fulfill()
        return .init(error: NSError(domain: "TEST", code: 0, userInfo: nil))
    }
}
