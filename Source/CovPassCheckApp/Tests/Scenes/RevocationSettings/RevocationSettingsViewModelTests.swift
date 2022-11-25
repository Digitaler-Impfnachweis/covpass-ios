//
//  RevocationSettingsViewModelTests.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassCheckApp
import CovPassCommon
import Foundation
import XCTest

class RevocationSettingsViewModelTests: XCTestCase {
    private var sut: RevocationSettingsViewModel!
    private var mockRouter: RevocationSettingsRouterMock!
    private var persistence: UserDefaultsPersistence!

    override func setUpWithError() throws {
        try super.setUpWithError()
        mockRouter = RevocationSettingsRouterMock()
        persistence = UserDefaultsPersistence()
        sut = RevocationSettingsViewModel(router: mockRouter, userDefaults: persistence)
    }

    override func tearDownWithError() throws {
        persistence = nil
        mockRouter = nil
        sut = nil
    }

    func test_expertMode_nil() throws {
        // GIVEN
        try persistence.delete(UserDefaults.keyRevocationExpertMode)

        // THEN
        XCTAssertFalse(sut.switchState)
    }

    func test_expertMode_false() {
        // WHEN
        persistence.revocationExpertMode = false

        // THEN
        XCTAssertFalse(sut.switchState)
    }

    func test_expertMode_true() {
        // WHEN
        persistence.revocationExpertMode = true

        // THEN
        XCTAssertTrue(sut.switchState)
    }

    func test_switchChanged_on() {
        // WHEN
        sut.switchChanged(isOn: true)

        // THEN
        XCTAssertTrue(sut.switchState)
        XCTAssertTrue(persistence.revocationExpertMode)
    }

    func test_switchChanged_false() {
        // WHEN
        sut.switchChanged(isOn: false)

        // THEN
        XCTAssertFalse(sut.switchState)
        XCTAssertFalse(persistence.revocationExpertMode)
    }
}
