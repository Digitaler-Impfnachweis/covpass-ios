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

    func testSha512() {
        XCTAssertEqual("abc123".data(using: .utf8)!.sha512().hexEncodedString(), "c70b5dd9ebfb6f51d09d4132b7170c9d20750a7852f00680f65658f0310e810056e6763c34c9a00b0e940076f54495c169fc2302cceb312039271c43469507dc")
    }
}
