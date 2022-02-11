//
//  AppInformationBaseViewModelTests.swift
//  
//
//  Created by Thomas Kuleßa on 09.02.22.
//

@testable import CovPassUI
import XCTest

class AppInformationBaseViewModelTests: XCTestCase {
    private var router: AppInformationRouterMock!
    private var sut: AppInformationBaseViewModel!

    override func setUpWithError() throws {
        router = .init()
        sut = AppInformationBaseViewModel(router: router, entries: [])
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
            entries: [],
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

    func testEntries() {
        // Given
        let givenEntries: [AppInformationEntry] = [
            .mock(),
            .init(title: UUID().uuidString, scene: SceneFactoryMock()),
            .mock(),
            .init(title: UUID().uuidString, scene: SceneFactoryMock()),
            .init(title: UUID().uuidString, scene: SceneFactoryMock()),
        ]
        sut = .init(router: router, entries: givenEntries)

        // When
        let entries = sut.entries

        // Then
        XCTAssertEqual(entries.count, 5)
        for index in 0..<min(entries.count, givenEntries.count) {
            XCTAssertEqual(entries[index].title, givenEntries[index].title)
        }
    }

    func testShowSceneForEntry() {
        // When
        sut.showSceneForEntry(.init(title: "", scene: SceneFactoryMock()))

        // Then
        wait(for: [router.showSceneExpectation], timeout: 2)
    }
}


