//
//  AppInformationBaseViewModelTests.swift
//  
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassUI
import XCTest

class AppInformationBaseViewModelTests: XCTestCase {
    private var router: AppInformationRouterMock!
    private var sut: AppInformationBaseViewModel!

    override func setUpWithError() throws {
        router = .init()
        sut = AppInformationBaseViewModel(router: router)
    }

    override func tearDownWithError() throws {
        sut = nil
    }

    func testAppVersionText() {
        // When
        let text = sut.appVersionText

        // Then
        XCTAssertEqual(text, AppInformationBaseViewModel.Texts.appVersion)
    }

    func testTitle() {
        // When
        let text = sut.title

        // Then
        XCTAssertEqual(text, AppInformationBaseViewModel.Texts.title)
    }

    func testDescriptionText() {
        // When
        let text = sut.descriptionText

        // Then
        XCTAssertEqual(text, AppInformationBaseViewModel.Texts.description)
    }

    func test_custom_texts() {
        // Given
        let title = UUID().uuidString
        let description = UUID().uuidString
        let version = UUID().uuidString
        sut = .init(
            router: router,
            title: title,
            descriptionText: description,
            appVersionText: version
        )

        // When & Then
        XCTAssertEqual(sut.title, title)
        XCTAssertEqual(sut.descriptionText, description)
        XCTAssertEqual(sut.appVersionText, version)
    }

    func testEntries_empty() {
        // When
        let entries = sut.entries

        // Then
        XCTAssertTrue(entries.isEmpty)
    }

    func testShowSceneForEntry() {
        // When
        sut.showSceneForEntry(.init(title: "", scene: SceneFactoryMock()))

        // Then
        wait(for: [router.showSceneExpectation], timeout: 2)
    }
}


