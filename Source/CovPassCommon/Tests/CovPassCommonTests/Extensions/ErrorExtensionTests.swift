//
//  ErrorExtensionTests.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import XCTest

@testable import CovPassCommon

enum ErrorWithoutCode: Error {
    case unknownError
}

class ErrorExtensionTests: XCTestCase {
    func testDisplayError() {
        XCTAssertEqual(ApplicationError.unknownError.displayCodeWithMessage("Oops"), "Oops (Error 901)")
        XCTAssertEqual(ErrorWithoutCode.unknownError.displayCodeWithMessage("Oops"), "Oops")
    }
}
