//
//  Bundle+ResourceURLTests.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassCommon
import Foundation
import XCTest

class Bundle_ResourceURLTests: XCTestCase {
    private var sut: Bundle!

    override func setUpWithError() throws {
        sut = .commonBundle
    }

    override func tearDownWithError() throws {
        sut = nil
    }

    func testGermanAnnouncementsURL() {
        // When
        let url = sut.germanAnnouncementsURL

        // Then
        XCTAssertNotNil(url)
    }

    func testEnglishAnnouncementsURL() {
        // When
        let url = sut.englishAnnouncementsURL

        // Then
        XCTAssertNotNil(url)
    }
}
