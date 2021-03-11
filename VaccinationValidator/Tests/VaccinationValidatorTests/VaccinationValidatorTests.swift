//
//  VaccinationValidatorTests.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

import XCTest
@testable import VaccinationValidator

final class VaccinationValidatorTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(VaccinationValidator().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
