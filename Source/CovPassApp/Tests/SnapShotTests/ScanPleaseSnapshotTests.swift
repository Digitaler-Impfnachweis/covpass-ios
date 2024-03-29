//
//  ScanPleaseSnapshotTests.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//
//

@testable import CovPassApp
import PromiseKit
import XCTest

class ScanPleaseSnapshotTests: BaseSnapShotTests {
    func testScanPlease() {
        let (_, resolver) = Promise<Void>.pending()
        let vm = ScanPleaseViewModel(router: ScanPleaseRouterMock(), resolvable: resolver)
        let vc = ScanPleaseViewController(viewModel: vm)
        verifyView(vc: vc)
    }
}
