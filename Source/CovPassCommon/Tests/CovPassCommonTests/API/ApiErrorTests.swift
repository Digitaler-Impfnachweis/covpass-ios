//
//  ApiErrorTests.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import XCTest

@testable import CovPassCommon

class ApiErrorTests: XCTestCase {
    func testErrorCode() {
        XCTAssertEqual(APIError.requestCancelled.errorCode, 101)
        XCTAssertEqual(APIError.compressionFailed.errorCode, 102)
        XCTAssertEqual(APIError.invalidUrl.errorCode, 103)
        XCTAssertEqual(APIError.invalidResponse.errorCode, 104)
    }
}
