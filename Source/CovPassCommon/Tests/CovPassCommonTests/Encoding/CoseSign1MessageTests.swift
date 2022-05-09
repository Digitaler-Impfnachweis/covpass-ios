//
//  CoseSign1MessageTests.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Compression
import SwiftCBOR
import XCTest

@testable import CovPassCommon

class CoseSign1MessageTests: XCTestCase {
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

        XCTAssertEqual(mappedDictionary?["4"] as? UInt64, 1_682_675_518)
        XCTAssertEqual(mappedDictionary?["1"] as? String, "IT")
        XCTAssertEqual(mappedDictionary?["6"] as? UInt64, 1_651_139_518)
    }

    func testInitJsonToJSON() throws {
        let finalCoseSign1Message = try CoseSign1Message(jsonData: jsonTestData)
        let finalJsonData = try finalCoseSign1Message.toJSON()
        let mappedDictionary = try JSONSerialization.jsonObject(with: finalJsonData, options: .allowFragments) as? [String: Any]

        XCTAssertEqual(mappedDictionary?["4"] as? UInt64, 1_651_936_419)
        XCTAssertEqual(mappedDictionary?["1"] as? String, "DE")
        XCTAssertEqual(mappedDictionary?["6"] as? UInt64, 1_620_400_419)
    }

    func testKeyIdentifier() {
        // Given
        let protected: [UInt8] = [
            162, 1, 38, 4, 72, 149, 207, 90, 247, 179, 22, 22, 27
        ]
        let sut = CoseSign1Message(
            protected: protected,
            unprotected: nil,
            payload: [],
            signature: []
        )

        // When
        let kid = sut.keyIdentifier

        // Then
        XCTAssertEqual(kid, [149, 207, 90, 247, 179, 22, 22, 27])
    }

    func testKeyIdentifier_key_4_missing() {
        // Given
        let protected: [UInt8] = [
            162, 1, 38, 5, 72, 149, 207, 90, 247, 179, 22, 22, 27
        ]
        let sut = CoseSign1Message(
            protected: protected,
            unprotected: nil,
            payload: [],
            signature: []
        )

        // When
        let kid = sut.keyIdentifier

        // Then
        XCTAssertTrue(kid.isEmpty)
    }

    func testKeyIdentifier_protected_missing() {
        // Given
        let sut = CoseSign1Message(
            protected: [],
            unprotected: nil,
            payload: [],
            signature: []
        )

        // When
        let kid = sut.keyIdentifier

        // Then
        XCTAssertTrue(kid.isEmpty)
    }

    func testKeyIdentifier_key_in_unprotected() {
        // Given
        let unprotected: [CBOR: CBOR] = [
            CBOR(integerLiteral: CoseProtectedHeader.kid.rawValue): .byteString([149, 207, 90, 247, 179, 22, 22, 27])
        ]
        let sut = CoseSign1Message(
            protected: [],
            unprotected: unprotected,
            payload: [],
            signature: []
        )

        // When
        let kid = sut.keyIdentifier

        // Then
        XCTAssertEqual(kid, [149, 207, 90, 247, 179, 22, 22, 27])
    }

    func testKeyIdentifier_protected_has_priority_over_unprotected() {
        // Given
        let protected: [UInt8] = [
            162, 1, 38, 4, 72, 123, 207, 90, 247, 183, 25, 0, 27
        ]
        let unprotected: [CBOR: CBOR] = [
            CBOR(integerLiteral: CoseProtectedHeader.kid.rawValue): .byteString([149, 207, 90, 247, 179, 22, 22, 27])
        ]
        let sut = CoseSign1Message(
            protected: protected,
            unprotected: unprotected,
            payload: [],
            signature: []
        )

        // When
        let kid = sut.keyIdentifier

        // Then
        XCTAssertEqual(kid, [123, 207, 90, 247, 183, 25, 0, 27])
    }

    func testRValueSignature_signature_missing() {
        // Given
        let sut = CoseSign1Message(
            protected: [],
            unprotected: nil,
            payload: [],
            signature: []
        )

        // When
        let rValueSignature = sut.rValueSignature

        // Then
        XCTAssertTrue(rValueSignature.isEmpty)
    }

    func testRValueSignature_signature_too_short() {
        // Given
        let signature = [UInt8](repeating: 1, count: 31)
        let sut = CoseSign1Message(
            protected: [],
            unprotected: nil,
            payload: [],
            signature: signature
        )

        // When
        let rValueSignature = sut.rValueSignature

        // Then
        XCTAssertTrue(rValueSignature.isEmpty)
    }

    func testRValueSignature_signature_correct() {
        // Given
        let rValueSignature = [UInt8](repeating: 1, count: 32)
        let sValueSignature = [UInt8](repeating: 2, count: 32)
        let sut = CoseSign1Message(
            protected: [],
            unprotected: nil,
            payload: [],
            signature: rValueSignature + sValueSignature
        )

        // When
        let signatue = sut.rValueSignature

        // Then
        XCTAssertEqual(signatue, rValueSignature)
    }

    func testToJSON_payload_with_binary_keys() throws {
        // Given
        let keys = [
            "f5c5970c3039d854",
            "f50159a32d84e89d",
            "69b71d69b71d69b71d",
            "6162636465666768",
            "07805b250c759584",
            "8c4ae0ed458b67f1"
        ]
        let base64EncodedCoseMessage = "0oRDoQEmoFhcpklptx1ptx1ptx2hQQoBSGFiY2RlZmdooUEKA0j1xZcMMDnYVKNBCgRBCwFBDAFIjErg7UWLZ/GhQQoCSAeAWyUMdZWEo0EKAkELAkEMAkj1AVmjLYTonaFBCwVYQPvCkhxAu2OpXTWXK5Fwcp5ghZWoquDDxu8ROlouygn6psPRt/AXVD0EBXBCNwqI6mp4ZKzUc2qdygskw9fuwwk="
        let data = try XCTUnwrap(Data(base64Encoded: base64EncodedCoseMessage))
        let sut = try CoseSign1Message(decompressedPayload: data)

        // When
        let jsonData = try sut.toJSON()

        // Then
        let json = try JSONSerialization.jsonObject(with: jsonData)
        guard let dictionary = json as? NSDictionary else {
            XCTFail("Must be a dictionary.")
            return
        }
        XCTAssertEqual(dictionary.count, 6)

        for key in keys {
            XCTAssertTrue(dictionary[key] is NSDictionary, "Key missing: \(key)")
        }

        guard let value = dictionary["f5c5970c3039d854"] as? NSDictionary else {
            XCTFail("Must be not nil and a dictionary.")
            return
        }
        XCTAssertNotNil(value["0a"])
        XCTAssertNotNil(value["0b"])
        XCTAssertNotNil(value["0c"])
    }

    func testToJSON_payload_with_array() throws {
        // Given
        let expectedArray: [[UInt8]] = [
            [0xb4,0x65,0xf7,0xf4,0x84,0xe7,0x56,0xe0,0xf6,0x56,0xf1,0x47,0xa0,0x74,0x30,0x0a],
            [0xef,0x47,0x6f,0x52,0x7e,0x98,0x5c,0x20,0x4e,0x7e,0x17,0x0e,0xb8,0x92,0xf3,0x75],
            [0xa6,0xb8,0xa0,0x1b,0x67,0x03,0x0f,0x32,0xe0,0xe3,0xd7,0x05,0x2a,0x71,0xa6,0x88],
            [0xec,0xe1,0x30,0xa1,0xfd,0x00,0x1c,0x7f,0xc6,0x19,0xf1,0xa0,0x19,0x5b,0x31,0xac]
        ]
        let base64EncodedMessage = "0oRDoQEmoFhFhFC0Zff0hOdW4PZW8UegdDAKUO9Hb1J+mFwgTn4XDriS83VQprigG2cDDzLg49cFKnGmiFDs4TCh/QAcf8YZ8aAZWzGsWEBzfym6BRubH/lzn4MpVo1M7K/d5+fY+Vt+670fTfHxdbXnRMojTWe45T2TKElsrWyciUVFPlHbTkTtdmS072Vu"
        let data = try XCTUnwrap(Data(base64Encoded: base64EncodedMessage))
        let sut = try CoseSign1Message(decompressedPayload: data)

        // When
        let jsonData = try sut.toJSON()

        // Then
        let json = try JSONSerialization.jsonObject(with: jsonData)
        guard let array = json as? [[UInt8]] else {
            XCTFail("Must be an array.")
            return
        }
        XCTAssertEqual(array, expectedArray)
    }

    func testRevocationSignatureHash() throws {
        // Given
        let expectedHash: [UInt8] = [
            166, 184, 160, 27, 103, 3, 15, 50,
            224, 227, 215, 5, 42, 113, 166, 136,
            150, 71, 162, 241, 54, 152, 75, 135,
            103, 137, 149, 147, 50, 197, 184, 99
        ]
        let base64EncodedMessage =
        "0oRNogEmBEj1xZcMMDnYVKBY8qQEGmPZq4AGGmId600BYkRFOQEDoQGkY3ZlcmUxLjMuMGNuYW2kYmZuak11c3Rlcm1hbm5jZm50ak1VU1RFUk1BTk5iZ25jTWF4Y2dudGNNQVhjZG9iajE5OTAtMDEtMDFhdoGqYnRnaTg0MDUzOTAwNmJ2cGoxMTE5MzQ5MDA3Ym1wbEVVLzEvMjAvMTUyOGJtYW1PUkctMTAwMDMwMjE1YmRuA2JzZANiZHRqMjAyMi0wMi0wMWJjb2JERWJpc2NSS0liY2l4KVVSTjpVVkNJOlYxOkRFOk1OSTVTSEJBVkRDNUpXRjBXSTYzSTVJUTY4WECqn/vjRh04QnGYrq78H4ffBMEFXygWO9c03pg4VccMKbBLVUQR/AKn1cvByvGVrM8lpVCH7THIihPQF3+GgZO3"
        let data = try XCTUnwrap(Data(base64Encoded: base64EncodedMessage))
        let sut = try CoseSign1Message(decompressedPayload: data)

        // When
        let hash = sut.revocationSignatureHash

        // Then
        XCTAssertEqual(hash, expectedHash)
    }
}
