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
    var cborTestData: Data {
        let certificate = CertificateMock.validCertificateNoPrefix
        let base45Decoded = (try? Base45Coder.decode(certificate)) ?? []
        return Compression.decompress(Data(base45Decoded)) ?? Data()
    }

    var jsonTestData: Data {
        let jsonString = "{\"4\":1651936419,\"1\":\"DE\",\"6\":1620400419,\"-260\":{\"1\":{\"ver\":\"1.0.0\",\"dob\":\"1997-01-06\",\"v\":[{\"tg\":\"840539006\",\"vp\":\"1119349007\",\"ma\":\"ORG-100030215\",\"mp\":\"EU\\/1\\/20\\/1528\",\"sd\":2,\"dt\":\"2021-02-28\",\"ci\":\"01DE\\/00100\\/1119349007\\/F4G7014KQQ2XD0NY8FJHSTDXZ#S\",\"is\":\"Bundesministerium für Gesundheit (Test01)\",\"dn\":2,\"co\":\"DE\"}],\"nam\":{\"fn\":\"Ionut\",\"fnt\":\"IONUT\",\"gn\":\"Balai\",\"gnt\":\"BALAI\"}}}}"
        let json = try! JSONSerialization.jsonObject(with: jsonString.data(using: .utf8)!, options: .allowFragments)
        return try! JSONSerialization.data(withJSONObject: json, options: .fragmentsAllowed)
    }

    func testErrorCode() {
        XCTAssertEqual(CoseParsingError.wrongType.errorCode, 401)
        XCTAssertEqual(CoseParsingError.wrongArrayLength.errorCode, 402)
        XCTAssertEqual(CoseParsingError.missingValue.errorCode, 403)
    }

    func testInitCBOR() throws {
        let coseSign1Message = try CoseSign1Message(decompressedPayload: cborTestData)

        guard coseSign1Message.payload.count > 0 else {
            XCTFail("Payload count should not be 0")
            return
        }

        XCTAssertNotNil(try? CBOR.decode(coseSign1Message.payload))
    }

    func testToJSON() throws {
        let coseSign1Message = try CoseSign1Message(decompressedPayload: cborTestData)

        let jsonData = try coseSign1Message.toJSON()
        let mappedDictionary = try JSONSerialization.jsonObject(with: jsonData, options: .allowFragments) as? [String: Any]

        XCTAssertEqual(mappedDictionary?["4"] as? UInt64, 1_651_936_419)
        XCTAssertEqual(mappedDictionary?["1"] as? String, "DE")
        XCTAssertEqual(mappedDictionary?["6"] as? UInt64, 1_620_400_419)
    }

    func testInitJsonToJSON() throws {
        let finalCoseSign1Message = try CoseSign1Message(jsonData: jsonTestData)
        let finalJsonData = try finalCoseSign1Message.toJSON()
        let mappedDictionary = try JSONSerialization.jsonObject(with: finalJsonData, options: .allowFragments) as? [String: Any]

        XCTAssertEqual(mappedDictionary?["4"] as? UInt64, 1_651_936_419)
        XCTAssertEqual(mappedDictionary?["1"] as? String, "DE")
        XCTAssertEqual(mappedDictionary?["6"] as? UInt64, 1_620_400_419)
    }
}
