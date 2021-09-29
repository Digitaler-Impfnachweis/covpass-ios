//
//  UserDefaultsPersistenceTests.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import XCTest

@testable import CovPassCommon

class UserDefaultsPersistenceTests: XCTestCase {
    func testUserDefaultsPersistence() {
        let randomKey = "\(Date().timeIntervalSince1970.rounded())"
        let sut = UserDefaultsPersistence()

        XCTAssertNil(try sut.fetch(randomKey))
        XCTAssertNoThrow(try sut.store(randomKey, value: "1"))
        XCTAssertEqual(try sut.fetch(randomKey) as? String, "1")
        XCTAssertNoThrow(try sut.delete(randomKey))
        XCTAssertNil(try sut.fetch(randomKey))
    }
}
