//
//  WhatsNewSettingsViewModelTests.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassUI
import Foundation
import XCTest

class WhatsNewSettingsViewModelTests: XCTestCase {
    private var persistence: MockPersistence!
    private var sut: WhatsNewSettingsViewModel!

    override func setUpWithError() throws {
        persistence = .init()
        sut = .init(
            persistence: persistence,
            whatsNewURL: FileManager.default.temporaryDirectory
        )
    }

    override func tearDownWithError() throws {
        persistence = nil
        sut = nil
    }

    func testDisableWhatsNew_false() {
        // When
        let isDisabled = sut.disableWhatsNew

        // Then
        XCTAssertFalse(isDisabled)
    }

    func testDisableWhatsNew_set() {
        // When
        sut.disableWhatsNew = true

        // Then
        XCTAssertTrue(persistence.disableWhatsNew)
    }

    func testWhatsNewURLRequest() {
        // Given
        let expectedRequest = URLRequest(url: FileManager.default.temporaryDirectory)
        // When
        let request = sut.whatsNewURLRequest

        // Then
        XCTAssertEqual(request, expectedRequest)
    }
}
