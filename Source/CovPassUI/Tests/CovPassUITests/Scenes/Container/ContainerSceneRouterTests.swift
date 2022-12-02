//
//  ContainerSceneRouterTests.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassUI
import XCTest

class ContainerSceneRouterTests: XCTestCase {
    func testRouting() {
        // GIVEN
        let mock = SceneCoordinatorMock()
        let sut = ContainerSceneRouter(sceneCoordinator: mock)

        // WHEN
        sut.dismiss()

        // THEN
        XCTAssert(mock.didDismissScene)
    }
}
