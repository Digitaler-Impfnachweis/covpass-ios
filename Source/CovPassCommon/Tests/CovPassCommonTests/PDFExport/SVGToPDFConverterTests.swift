//
//  SVGToPDFConverterTests.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassCommon
import XCTest

class SVGToPDFConverterTests: XCTestCase {
    private var sut: SVGToPDFConverter!
    override func setUpWithError() throws {
        sut = SVGToPDFConverter()
    }

    override func tearDownWithError() throws {
        sut = nil
    }

    func testConvert_success() throws {
        // Given
        let svgData = """
            <svg version="1.1" width="300" height="200" xmlns="http://www.w3.org/2000/svg"></svg>
        """.data(using: .utf8)
        let data: Data = try XCTUnwrap(svgData)
        let expectation = XCTestExpectation()

        // When
        sut.convert(data)
            .done { _ in
                expectation.fulfill()
            }
            .catch { _ in
                XCTFail("Must not fail.")
            }

        // Then
        wait(for: [expectation], timeout: 3)
    }
}
