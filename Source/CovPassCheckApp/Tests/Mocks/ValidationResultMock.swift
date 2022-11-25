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
    var showStartExpectation = XCTestExpectation(description: "showStartExpectation")
    var showRevocationExpectation = XCTestExpectation()
    var sceneCoordinator: SceneCoordinator = SceneCoordinatorMock()

    func showStart() {
        showStartExpectation.fulfill()
    }

    func scanQRCode() -> Promise<QRCodeImportResult> {
        .value(.scanResult(.success("")))
    }

    func showRevocation(token _: ExtendedCBORWebToken, keyFilename _: String) -> Promise<Void> {
        showRevocationExpectation.fulfill()
        return .init(error: NSError(domain: "TEST", code: 0, userInfo: nil))
    }
}
