//
//  DataBase45Tests.swift
//  
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassCommon
import Foundation
import XCTest

class DataBase45Tests: XCTestCase {
    func testBase45Encode() throws {
        // Given
        let expectation = XCTestExpectation()
        let sut = try XCTUnwrap("123".data(using: .ascii))

        // When
        sut.base45Encode
            .done { string in
                XCTAssertEqual(string, "*9661")
                expectation.fulfill()
            }
            .cauterize()

        // Then
        wait(for: [expectation], timeout: 2)
    }
}
