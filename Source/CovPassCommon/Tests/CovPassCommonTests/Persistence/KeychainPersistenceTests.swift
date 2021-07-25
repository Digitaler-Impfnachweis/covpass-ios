//
//  KeychainPersistenceTests.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import XCTest

@testable import CovPassCommon

class KeychainPersistenceTests: XCTestCase {
    func testErrorCode() {
        XCTAssertEqual(KeychainError.valueNotData.errorCode, 501)
        XCTAssertEqual(KeychainError.storeUpdateFailed.errorCode, 502)
        XCTAssertEqual(KeychainError.storeAddFailed.errorCode, 503)
        XCTAssertEqual(KeychainError.fetchFailed.errorCode, 504)
        XCTAssertEqual(KeychainError.deleteFailed.errorCode, 505)
        XCTAssertEqual(KeychainError.migrationFailed.errorCode, 506)
    }
}
