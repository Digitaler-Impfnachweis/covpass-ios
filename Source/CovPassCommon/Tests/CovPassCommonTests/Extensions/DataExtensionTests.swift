//
//  DataExtensionTests.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import XCTest

@testable import CovPassCommon

class DataExtensionTests: XCTestCase {
    func testSha256() {
        XCTAssertEqual("abc123".data(using: .utf8)!.sha256().hexEncodedString(), "6ca13d52ca70c883e0f0bb101e425a89e8624de51db2d2392593af6a84118090")
    }
}
