//
//  ContainerFactoryTests.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassUI
import XCTest

class ContainerFactoryTests: XCTestCase {
    func testMake() {
        let sut = ContainerSceneFactory(
            title: "foo",
            embeddedViewController: SceneFactoryMock(),
            sceneCoordinator: SceneCoordinatorMock()
        ).make()
        XCTAssert(sut is ContainerViewController)
    }
}
