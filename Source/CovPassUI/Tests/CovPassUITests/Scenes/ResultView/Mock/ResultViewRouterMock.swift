//
//  ResultViewRouterMock.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import CovPassUI
import Foundation
import PromiseKit
import XCTest

class ResultViewRouterMock: ResultViewRouterProtocol {
    var sceneCoordinator: SceneCoordinator = SceneCoordinatorMock()
    var showPdfExpectation = XCTestExpectation()

    func showPDFExport(for _: ExtendedCBORWebToken) -> Promise<Void> {
        showPdfExpectation.fulfill()
        return .value
    }
}
