//
//  ScanCountWarningViewSnapShotTests.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassApp
@testable import CovPassCommon
import XCTest

class ScanCountWarningViewSnapShotTests: BaseSnapShotTests {
    func testDefault() {
        let vm = ScanCountWarningViewModel(router: nil,
                                           resolvable: nil)
        let vc = ScanCountWarningViewController(viewModel: vm)
        verifyView(vc: vc)
    }
}
