//
//  ArrayExtensionTests.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import XCTest

@testable import CovPassCommon

class ArrayExtensionTests: XCTestCase {
    private var sut: Array<Int>!

    override func setUpWithError() throws {
        sut = [72, 101, 108, 108, 111, 33, 33]
    }

    override func tearDownWithError() throws {
        sut = nil
    }

    func testChunked() {
        XCTAssertEqual(sut.chunked(into: 3).count, 3)
        XCTAssertEqual(sut.chunked(into: 10).count, 1)
        XCTAssertEqual(sut.chunked(into: 0).count, 1)
    }

    func testTakeFirst_more_than_available() {
        // When
        let subarray = sut.takeFirst(10)

        // Then
        XCTAssertEqual(subarray, sut)
    }

    func testTakeFirst_3() {
        // When
        let subarray = sut.takeFirst(3)

        // Then
        XCTAssertEqual(subarray, [72, 101, 108])
    }

    func testTakeFirst_negative_number() {
        // When
        let subarray = sut.takeFirst(-10)

        // Then
        XCTAssertTrue(subarray.isEmpty)
    }
}
