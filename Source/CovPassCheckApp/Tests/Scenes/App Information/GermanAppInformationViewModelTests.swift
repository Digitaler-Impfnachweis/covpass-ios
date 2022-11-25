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
            "settings_rules_list_title".localized,
            AppInformationBaseViewModel.Texts.faqTitle,
            "app_information_beep_when_checking_title".localized,
            AppInformationBaseViewModel.Texts.leichteSprache,
            AppInformationBaseViewModel.Texts.contactTitle,
            AppInformationBaseViewModel.Texts.datenschutzTitle,
            AppInformationBaseViewModel.Texts.companyDetailsTitle,
            AppInformationBaseViewModel.Texts.openSourceLicenseTitle,
            AppInformationBaseViewModel.Texts.accessibilityStatementTitle,
            "app_information_authorities_function_title".localized
        ]
        let sut = GermanAppInformationViewModel(
            router: AppInformationRouterMock(),
            userDefaults: MockPersistence()
        )

        // When
        let entries = sut.entries

        // Then
        XCTAssertEqual(entries.count, 10)
        for index in 0 ..< min(entries.count, expectedTitles.count) {
            XCTAssertEqual(entries[index].title, expectedTitles[index])
        }
    }
}
