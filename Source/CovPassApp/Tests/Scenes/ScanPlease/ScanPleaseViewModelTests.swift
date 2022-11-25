//
//  ScanPleaseViewModelTests.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassApp
@testable import CovPassUI

import Foundation
import PromiseKit
import XCTest

class ScanPleaseViewModelTests: XCTestCase {
    private var sut: ScanPleaseViewModel!
    private let routerMock = ScanPleaseRouterMock()

    override func setUpWithError() throws {
        let (_, resolver) = Promise<Void>.pending()
        sut = ScanPleaseViewModel(router: routerMock, resolvable: resolver)
    }

    func testViewModel() throws {
        XCTAssertEqual(sut.title, "certificates_start_screen_pop_up_app_reference_title".localized)
        XCTAssertEqual(sut.text, "certificate_start_screen_pop_up_app_reference_text".localized)
        XCTAssertEqual(sut.linkDescription, "certificate_popup_checkapp_link_label".localized)
        XCTAssertEqual(sut.linkText, "certificates_start_screen_pop_up_app_reference_hyperlink".localized)
    }
}

struct ScanPleaseRouterMock: ScanPleaseRoutable {
    func routeToCheckApp() {}

    var sceneCoordinator: SceneCoordinator = SceneCoordinatorMock()
}

private extension String {
    var localized: String {
        Localizer.localized(self, bundle: .main)
    }
}
