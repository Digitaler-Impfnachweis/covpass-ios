//
//  WhatsNewSettingsSceneFactoryTests.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassUI
import XCTest

class WhatsNewSettingsSceneFactoryTests: XCTestCase {
    func testMake() {
        // Given
        let sut = WhatsNewSettingsSceneFactory(
            router: WhatsNewSettingsRouterMock()
        )

        // When
        let viewController = sut.make()

        // Then
        XCTAssertTrue(viewController is WhatsNewSettingsViewController)
    }
}
