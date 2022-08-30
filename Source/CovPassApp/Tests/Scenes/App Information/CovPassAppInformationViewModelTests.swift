//
//  CovPassAppInformationViewModelTests.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassApp
import CovPassUI
import XCTest

class CovPassAppInformationViewModelTests: XCTestCase {
    private var persistence: MockPersistence!
    private var sut: CovPassAppInformationViewModel!

    override func setUpWithError() throws {
        let entries: [AppInformationEntry] = [
            .init(title: "TEST", scene: SceneFactoryMock())
        ]
        persistence = .init()
        sut = .init(
            router: AppInformationRouterMock(),
            entries: entries,
            persistence: persistence
        )
    }

    override func tearDownWithError() throws {
        persistence = nil
        sut = nil
    }

    func testEntries_whats_new_enabled() {
        // When
        let entries = sut.entries

        // Then
        XCTAssertEqual(entries.count, 2)
        XCTAssertEqual(entries.first?.title, "TEST")
        let whatsNewSettingsEntry = entries.last
        XCTAssertEqual(whatsNewSettingsEntry?.title, "Update notifications")
        XCTAssertEqual(whatsNewSettingsEntry?.rightTitle, "On")
        XCTAssertTrue(whatsNewSettingsEntry?.scene is WhatsNewSettingsSceneFactory)
    }

    func testEntries_whats_new_disabled() {
        // Given
        persistence.disableWhatsNew = true

        // When
        let entries = sut.entries

        // Then
        XCTAssertEqual(entries.last?.rightTitle, "Off")
    }

}
