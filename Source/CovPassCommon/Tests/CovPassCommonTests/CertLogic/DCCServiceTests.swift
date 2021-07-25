//
//  DCCServiceTests.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassCommon
import Foundation
import XCTest

class DCCServiceTests: XCTestCase {
    func testErrorCode() {
        XCTAssertEqual(DCCServiceError.requestCancelled.errorCode, 101)
        XCTAssertEqual(DCCServiceError.invalidURL.errorCode, 103)
        XCTAssertEqual(DCCServiceError.invalidResponse.errorCode, 104)
    }
}
