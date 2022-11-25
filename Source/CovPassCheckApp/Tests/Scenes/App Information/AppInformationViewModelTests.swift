//
//  AppInformationViewModelTests.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassCheckApp
import CovPassCommon
import CovPassUI
import XCTest

class CheckAppInformationBaseViewModelTests: XCTestCase {
    func testEntries_empty() {
        // Given
        let sut = prepareSut()

        // When
        let entries = sut.entries

        // Then
        XCTAssertEqual(entries.count, 3)
    }

    private func prepareSut(with persistence: Persistence = MockPersistence()) -> CheckAppInformationBaseViewModel {
        CheckAppInformationBaseViewModel(
            router: AppInformationRouterMock(),
            userDefaults: persistence
        )
    }

    func testEntries_checking_rules_right_title_nil() throws {
        // Given
        let sut = prepareSut()

        // When
        let entries = sut.entries

        // Then
        let entry = try XCTUnwrap(entries[0])
        XCTAssertNil(entry.rightTitle)
    }

    func testEntries_expertMode_default() throws {
        // Given
        let expectedTitle = "app_information_authorities_function_state_off".localized
        let persistence = UserDefaultsPersistence()
        try persistence.delete(UserDefaults.keyRevocationExpertMode)
        let sut = prepareSut(with: persistence)

        // When
        let entries = sut.entries

        // Then
        let entry = try XCTUnwrap(entries[1])
        XCTAssertEqual(entry.rightTitle, expectedTitle)
    }

    func testEntries_expertMode_false() throws {
        // Given
        let expectedTitle = "app_information_authorities_function_state_off".localized
        var persistence = UserDefaultsPersistence()
        persistence.revocationExpertMode = false
        let sut = prepareSut(with: persistence)

        // When
        let entries = sut.entries

        // Then
        let entry = try XCTUnwrap(entries[1])
        XCTAssertEqual(entry.rightTitle, expectedTitle)
    }

    func testEntries_expertMode_true() throws {
        // Given
        let expectedTitle = "app_information_authorities_function_state_on".localized
        var persistence = UserDefaultsPersistence()
        persistence.revocationExpertMode = true
        let sut = prepareSut(with: persistence)

        // When
        let entries = sut.entries

        // Then
        let entry = try XCTUnwrap(entries[1])
        XCTAssertEqual(entry.rightTitle, expectedTitle)
    }

    func testEntries_enableAcousticFeedback_false() throws {
        // Given
        let expectedTitle = "Off"
        var persistence = MockPersistence()
        persistence.enableAcousticFeedback = false
        let sut = prepareSut(with: persistence)

        // When
        let entries = sut.entries

        // Then
        let entry = try XCTUnwrap(entries[1])
        XCTAssertEqual(entry.rightTitle, expectedTitle)
    }

    func testEntries_enableAcousticFeedback_true() throws {
        // Given
        let expectedTitle = "On"
        var persistence = MockPersistence()
        persistence.revocationExpertMode = true
        let sut = prepareSut(with: persistence)

        // When
        let entries = sut.entries

        // Then
        let entry = try XCTUnwrap(entries[1])
        XCTAssertEqual(entry.rightTitle, expectedTitle)
    }
}
