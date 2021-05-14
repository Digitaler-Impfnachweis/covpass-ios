//
//  ArrayExtensionTests.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import XCTest

@testable import VaccinationCommon

class ArrayExtensionTests: XCTestCase {
    let sut = [72, 101, 108, 108, 111, 33, 33]

    func testChunked() {
        XCTAssertEqual(sut.chunked(into: 3).count, 3)
        XCTAssertEqual(sut.chunked(into: 10).count, 1)
        XCTAssertEqual(sut.chunked(into: 0).count, 1)
    }
}
