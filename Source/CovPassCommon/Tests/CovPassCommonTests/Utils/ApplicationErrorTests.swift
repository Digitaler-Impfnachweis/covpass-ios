//
//  ApplicationErrorTests.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import XCTest

@testable import CovPassCommon

class ApplicationErrorTests: XCTestCase {
    func testErrorCode() {
        XCTAssertEqual(ApplicationError.unknownError.errorCode, 901)
        XCTAssertEqual(ApplicationError.general("").errorCode, 902)
        XCTAssertEqual(ApplicationError.missingData("").errorCode, 903)
    }

    func testErrorMessage() {
        XCTAssertEqual(ApplicationError.unknownError.localizedDescription, "UnexpectedError")
        XCTAssertEqual(ApplicationError.general("foo").localizedDescription, "UnexpectedError\nfoo")
        XCTAssertEqual(ApplicationError.missingData("bar").localizedDescription, "UnexpectedError\nMissing Object: bar")
    }

    func testComparision() {
        XCTAssert(ApplicationError.general("foo") == ApplicationError.general("foo"))
        XCTAssertFalse(ApplicationError.general("foo") == ApplicationError.general("bar"))
    }
}
