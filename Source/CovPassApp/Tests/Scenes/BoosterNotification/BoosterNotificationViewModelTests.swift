//
//  BoosterNotificationViewModelTests.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassApp

import Foundation
import PromiseKit
import XCTest

class BoosterNotificationViewModelTests: XCTestCase {
    private var sut: BoosterNotificationViewModel!

    override func setUp() {
        super.setUp()
        let (_, resolver) = Promise<Void>.pending()
        sut = BoosterNotificationViewModel(resolvable: resolver)
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func testViewModel() {
        XCTAssertEqual(sut.title, "dialog_booster_vaccination_notification_title".localized)
        XCTAssertEqual(sut.actionButtonTitle, "dialog_booster_vaccination_notification_button".localized)
        XCTAssertEqual(sut.disclaimerText, "dialog_booster_vaccination_notification_message".localized)
        XCTAssertEqual(sut.highlightLabelText, "vaccination_certificate_overview_booster_vaccination_notification_icon_new".localized)
    }
}
