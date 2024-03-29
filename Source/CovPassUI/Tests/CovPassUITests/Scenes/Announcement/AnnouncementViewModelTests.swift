//
//  AnnouncementViewModelTests.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
@testable import CovPassUI
import PromiseKit
import XCTest

class AnnouncementViewModelTests: XCTestCase {
    private var persistence: MockPersistence!
    private var promise: Promise<Void>!
    private var sut: AnnouncementViewModel!

    override func setUpWithError() throws {
        let (promise, resolver) = Promise<Void>.pending()
        self.promise = promise
        persistence = .init()
        sut = .init(
            router: AnnouncementRouter(sceneCoordinator: SceneCoordinatorMock()),
            resolvable: resolver,
            persistence: persistence,
            whatsNewURL: FileManager.default.temporaryDirectory
        )
    }

    override func tearDownWithError() throws {
        persistence = nil
        promise = nil
        sut = nil
    }

    func testWhatsNewURL() throws {
        // When
        let url = sut.whatsNewURL

        // Then
        XCTAssertEqual(url, FileManager.default.temporaryDirectory)
    }

    func testDone() {
        // Given
        let expectation = XCTestExpectation()
        promise.done { _ in
            expectation.fulfill()
        }.cauterize()

        // When
        sut.done()

        // Then
        wait(for: [expectation], timeout: 1)
    }

    func testCancel() {
        // Given
        let expectation = XCTestExpectation()
        promise.done { _ in
            expectation.fulfill()
        }.cauterize()

        // When
        sut.cancel()

        // Then
        wait(for: [expectation], timeout: 1)
    }

    func testDisbaleWhatsNew_default() {
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

    func testCheckboxAccessibilityValue_default() {
        // When
        let value = sut.checkboxAccessibilityValue

        // Then
        XCTAssertEqual(value, "settings_list_status_off")
    }

    func testCheckboxAccessibilityValue_true() {
        // Given
        sut.disableWhatsNew = true

        // When
        let value = sut.checkboxAccessibilityValue

        // Then
        XCTAssertEqual(value, "settings_list_status_on")
    }
}
