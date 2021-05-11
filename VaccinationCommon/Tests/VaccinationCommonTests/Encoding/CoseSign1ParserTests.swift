//
//  CoseSign1ParserTests.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

import Compression
import SwiftCBOR
import XCTest

@testable import VaccinationCommon

class CoseSign1ParserTests: XCTestCase {
    var sut: CoseSign1Parser!
    var base45Encoder: Base45Coder!

    var testData: Data {
        let certificate = CertificateMock.validCertificateNoPrefix
        let base45Decoded = (try? base45Encoder.decode(certificate)) ?? []
        return Compression.decompress(Data(base45Decoded)) ?? Data()
    }

    override func setUp() {
        super.setUp()
        sut = CoseSign1Parser()
        base45Encoder = Base45Coder()
    }

    override func tearDown() {
        sut = nil
        base45Encoder = nil
        super.tearDown()
    }

    func testParsing() {
        let coseSign1Message = try! sut.parse(testData)

        guard let message = coseSign1Message else {
            XCTFail("Cose1SignMessage should not be nil")
            return
        }
        guard message.payload.count > 0 else {
            XCTFail("Payload count should not be 0")
            return
        }

        XCTAssertNotNil(try? CBOR.decode(message.payload))
    }

    func testMapping() throws {
        let coseSign1Message = try sut.parse(testData)

        guard let message = coseSign1Message else {
            XCTFail("Cose1SignMessage should not be nil")
            return
        }
        let mappedDictionary = sut.map(cborObject: try? CBOR.decode(message.payload))

        XCTAssertEqual(mappedDictionary?["4"] as? UInt64, 1_651_936_419)
        XCTAssertEqual(mappedDictionary?["1"] as? String, "DE")
        XCTAssertEqual(mappedDictionary?["6"] as? UInt64, 1_620_400_419)
    }
}
