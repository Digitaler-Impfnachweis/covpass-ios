//
//  DataBase45Tests.swift
//  
//
//  Created by Thomas Kuleßa on 21.02.22.
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
