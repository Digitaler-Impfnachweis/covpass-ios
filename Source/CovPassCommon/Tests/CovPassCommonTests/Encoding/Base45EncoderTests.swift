//
//  Base45CoderTests.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import SwiftCBOR
import XCTest

@testable import CovPassCommon

class Base45CoderTests: XCTestCase {
    var sut: Base45Coder!
    let rawToBase45: [String: String] = [
        "AB": "BB8", "Hello!!": "%69 VD92EX0", "base-45": "UJCLQE7W581", "ietf!": "QED8WEX0", "x": "U2", "": ""
    ]

    override func setUp() {
        super.setUp()
        sut = Base45Coder()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func testSuccessfulEncoding() {
        rawToBase45.forEach { key, value in
            var asciiValues = [UInt8]()
            key.forEach { character in
                if let asciiValue = character.asciiValue {
                    asciiValues.append(asciiValue)
                }
            }
            XCTAssertEqual(sut.encode(asciiValues), value)
        }
    }

    func testSuccessfulDecoding() {
        rawToBase45.forEach { key, value in
            var result = ""
            do {
                try sut.decode(value).forEach { integer in
                    result.append(Character(UnicodeScalar(integer)))
                }
                XCTAssertEqual(key, result)
            } catch {
                XCTFail(error.localizedDescription)
            }
        }
    }

    func testInvalidDecoding() {
        let base45Payload = [":::", "ZZZ", "+++"]
        base45Payload.forEach { entry in
            do {
                try _ = sut.decode(entry)
                XCTFail("Output for \(entry) should be invalid")
            } catch {
                XCTAssertNotNil(error as? Base45CodingError)
            }
        }
    }
}
