//
//  Base45EncoderTests.swift
//  
//
//  Copyright © 2021 IBM. All rights reserved.
//

import Foundation
import SwiftCBOR
import XCTest

@testable import VaccinationCommon

class Base45EncoderTests: XCTestCase {
    var sut: Base45Encoder!
    let rawToBase45: Dictionary<String, String> = [
        "AB": "BB8", "Hello!!": "%69 VD92EX0", "base-45": "UJCLQE7W581", "ietf!": "QED8WEX0", "x": "U2", "":""
    ]

    override func setUp() {
        super.setUp()
        sut = Base45Encoder()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func testSucccessfulEncoding() {
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
            sut.decode(value).forEach { integer in
                result.append(Character(UnicodeScalar(integer)))
            }
            XCTAssertEqual(key, result)
        }
    }
}
