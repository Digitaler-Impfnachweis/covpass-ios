//
//  StringExtensionTests.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

import Foundation
import XCTest

@testable import VaccinationCommon

class StringExtensionTests: XCTestCase {
    func testStripPrefix() {
        XCTAssertEqual("HC1:ABC123".stripPrefix(), "ABC123")
        XCTAssertEqual("HC2:ABC123".stripPrefix(), "HC2:ABC123")
        XCTAssertEqual("ABC123HC1:".stripPrefix(), "ABC123HC1:")
        XCTAssertEqual(" HC1:ABC123".stripPrefix(), " HC1:ABC123")
    }
}
