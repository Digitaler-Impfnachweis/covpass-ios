//
//  DictionaryExtensionTests.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import XCTest

@testable import CovPassCommon

class DictionaryExtensionTests: XCTestCase {
    let sut: [Int: String] = [0: "A", 1: "B", 2: "C", 3: "D", 4: "A", 5: "B", 6: "F", 7: "G", 8: "H", 9: "R", 10: "A", 11: "B"]

    func testGetMultipleKeys() {
        XCTAssertEqual(sut.getKeys(for: "A").count, 3)
    }

    func testGetNoKey() {
        XCTAssertEqual(sut.getKeys(for: "S").count, 0)
    }
}
