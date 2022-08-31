//
//  AcousticFeedbackSettingsSceneFactoryTests.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassCheckApp
import XCTest

class AcousticFeedbackSettingsSceneFactoryTests: XCTestCase {
    func testMake() {
        // Given
        let sut = AcousticFeedbackSettingsSceneFactory(
            router: AcousticFeedbackSettingsRouterMock()
        )

        // When
        _ = sut.make()
    }
}
