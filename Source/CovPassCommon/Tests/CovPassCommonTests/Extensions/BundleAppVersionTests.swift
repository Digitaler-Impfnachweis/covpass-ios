//
//  BundleAppVersionTests.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import XCTest

@testable import CovPassCommon

class BundleAppVersionTests: XCTestCase {
    func testDefaultAppVersion() {
        let sut = Bundle()
        XCTAssertEqual(sut.appVersion(), "1.0")
    }
}
