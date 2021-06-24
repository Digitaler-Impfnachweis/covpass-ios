//
//  ECDSATests.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import XCTest

@testable import CovPassCommon

class ECDSATests: XCTestCase {
    func testConvertSignatureData() throws {
        let validSignature = Data(base64Encoded: "vXqC8XOlCzvL4a5wUDjy/v2khd/vMYKAy3tXjt/inH1hbhxMP5w6fG0iY7usgI2oeX900R+X6upMkfvbbP98mA==")!
        _ = try ECDSA.convertSignatureData(validSignature)
    }

    func testConvertSignatureDataShortInvalidData() throws {
        let invalidSignature = "invalid".data(using: .utf8)!
        _ = try ECDSA.convertSignatureData(invalidSignature)
    }

    func testConvertSignatureDataInvalidData() throws {
        let invalidSignature = "this is an extra long invalid singature".data(using: .utf8)!
        _ = try ECDSA.convertSignatureData(invalidSignature)
    }

    func testConvertSignatureDataEmptyData() throws {
        let emptySignature = Data()
        _ = try ECDSA.convertSignatureData(emptySignature)
    }
}
