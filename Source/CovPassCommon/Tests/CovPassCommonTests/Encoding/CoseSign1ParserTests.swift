//
//  CoseSign1ParserTests.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Compression
import SwiftCBOR
import XCTest

@testable import CovPassCommon

class CoseSign1ParserTests: XCTestCase {
    var testData: Data {
        let certificate = CertificateMock.validCertificateNoPrefix
        let base45Decoded = (try? Base45Coder.decode(certificate)) ?? []
        return Compression.decompress(Data(base45Decoded)) ?? Data()
    }

    func testErrorCode() {
        XCTAssertEqual(CoseParsingError.wrongType.errorCode, 401)
        XCTAssertEqual(CoseParsingError.wrongArrayLength.errorCode, 402)
        XCTAssertEqual(CoseParsingError.missingValue.errorCode, 403)
    }

    func testParsing() throws {
        let coseSign1Message = try CoseSign1Message(decompressedPayload: testData)

        guard coseSign1Message.payload.count > 0 else {
            XCTFail("Payload count should not be 0")
            return
        }

        XCTAssertNotNil(try? CBOR.decode(coseSign1Message.payload))
    }

    func testMapping() throws {
        let coseSign1Message = try CoseSign1Message(decompressedPayload: testData)

        let mappedDictionary = coseSign1Message.map(cborObject: try? CBOR.decode(coseSign1Message.payload))

        XCTAssertEqual(mappedDictionary?["4"] as? UInt64, 1_651_936_419)
        XCTAssertEqual(mappedDictionary?["1"] as? String, "DE")
        XCTAssertEqual(mappedDictionary?["6"] as? UInt64, 1_620_400_419)
    }
}
