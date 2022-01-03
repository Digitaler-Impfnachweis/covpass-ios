//
//  ScanCountWarningViewSnapShotTests.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import XCTest
@testable import CovPassApp
@testable import CovPassCommon

class ScanCountWarningViewSnapShotTests: BaseSnapShotTests {
    
    func testDefault() {
        let vm = ScanCountWarningViewModel(router: nil,
                                           resolvable: nil)
        let vc = ScanCountWarningViewController(viewModel: vm)
        verifyView(vc: vc)
    }
}
