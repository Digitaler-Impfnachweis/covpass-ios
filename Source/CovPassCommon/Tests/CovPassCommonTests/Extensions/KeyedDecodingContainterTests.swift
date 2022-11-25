//
//  BundleAppVersionTests.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import XCTest

@testable import CovPassCommon

class KeyedDecodingContainterTests: XCTestCase {
    func testTrimmedDecoding() {
        let json = ["trimmedString": "  test  "]
        let data = try! JSONSerialization.data(withJSONObject: json, options: .fragmentsAllowed)
        let expected = try! JSONDecoder().decode(TestStruct.self, from: data)
        XCTAssertTrue(expected.trimmedString == "test")
    }

    func testTrimmedStringWithDefault() {
        let json = ["trimmedString": "  test  "]
        let data = try! JSONSerialization.data(withJSONObject: json, options: .fragmentsAllowed)
        let expected = try! JSONDecoder().decode(TestStruct.self, from: data)
        XCTAssertTrue(expected.trimmedString == "test")
        XCTAssertTrue(expected.trimmedDefaultString == "DE")
    }

    func testTrimmedStringWithoutDefault() {
        let json = ["trimmedString": "  test  ", "trimmedDefaultString": "AT"]
        let data = try! JSONSerialization.data(withJSONObject: json, options: .fragmentsAllowed)
        let expected = try! JSONDecoder().decode(TestStruct.self, from: data)
        XCTAssertTrue(expected.trimmedString == "test")
        XCTAssertTrue(expected.trimmedDefaultString == "AT")
    }
}

private struct TestStruct: Codable {
    let trimmedString: String
    let trimmedDefaultString: String

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        trimmedString = try container.decodeTrimmedString(forKey: .trimmedString)
        trimmedDefaultString = try container.decodeStringIfPresentOr(defaultValue: "DE", forKey: .trimmedDefaultString)
    }
}
