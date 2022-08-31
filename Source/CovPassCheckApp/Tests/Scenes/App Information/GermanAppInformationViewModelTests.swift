//
//  GermanAppInformationViewModelTests.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassCheckApp
import CovPassCommon
import CovPassUI
import XCTest

class GermanAppInformationViewModelTests: XCTestCase {
    func testEntries_default() {
        // Given
        let expectedTitles = [
            AppInformationBaseViewModel.Texts.leichteSprache,
            AppInformationBaseViewModel.Texts.contactTitle,
            AppInformationBaseViewModel.Texts.faqTitle,
            AppInformationBaseViewModel.Texts.datenschutzTitle,
            AppInformationBaseViewModel.Texts.companyDetailsTitle,
            AppInformationBaseViewModel.Texts.openSourceLicenseTitle,
            AppInformationBaseViewModel.Texts.accessibilityStatementTitle,
            AppInformationBaseViewModel.Texts.appInformationTitle,
        ]
        let sut = GermanAppInformationViewModel(
            router: AppInformationRouterMock(),
            userDefaults: MockPersistence()
        )

        // When
        let entries = sut.entries

        // Then
        XCTAssertEqual(entries.count, 10)
        for index in 0..<min(entries.count, expectedTitles.count) {
            XCTAssertEqual(entries[index].title, expectedTitles[index])
        }
    }
}
