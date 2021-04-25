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
    var base45Encoder: Base45Encoder!

    override func setUp() {
        super.setUp()
        sut = CoseSign1Parser()
        base45Encoder = Base45Encoder()
    }

    override func tearDown() {
        sut = nil
        base45Encoder = nil
        super.tearDown()
    }

    func testParsing() {
        let decompressedPayload = prepareData()
        let coseSign1Message = try? sut.parse(decompressedPayload)

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
        let decompressedPayload = prepareData()
        let coseSign1Message = try? sut.parse(decompressedPayload)

        guard let message = coseSign1Message else {
            XCTFail("Cose1SignMessage should not be nil")
            return
        }
        let mappedDictionary = sut.map(cborObject: try? CBOR.decode(message.payload))

        XCTAssertEqual(mappedDictionary?["issuer"] as? String, "Landratsamt Altötting")
        XCTAssertEqual(mappedDictionary?["identifier"] as? String, "C01X00T47")
        XCTAssertNotNil(mappedDictionary?["vaccination"])
        XCTAssertEqual(mappedDictionary?["id"] as? String, "01DE/84503/1119349007/DXSGWLWL40SU8ZFKIYIBK39A3#S")
    }
}

extension CoseSign1ParserTests {
    func prepareData() -> Data {
        let qrCodeString = "6BFXZ8J18OJ28S2$61XJGVNK3*KF HPCCQ*4IOR5-TOI9QF9 YH-R8XHHC11KTM54EV15**JP.C7P8JM7I32QI1VQ0JUQSM9J/1$N5SPPBFM3B21JBY/R5NU4OU$8IJ-F4FV28LYTG48M.5JU8T-0IV%DJQDOKM+1B+MQ$X34AD-VHNZ7S9D4:O0%B-*RAYOK8PZ$41Q0W:EY55472AQK/BIKV9NXP4H1DS8$8GZVQ/-6V-8TFGR-RX44/X1770G 7 LK+ P4-1WG2A9FT75KKGY%3K1S:49JNTNRLGO0LD0F/3BX4POU U0UB65B2KIR5T1BC4:8KHDJAXAXTRV1F/.AZPR*.GMF9MA2VGAFLEW:FQAPD+3%EK16WATE+:2-I4MQN6UC:AI0/L4MUX.AGS6MC80 7ZHC.N1RPASS0YE1L/GIZH4%2$A6DF2/ DZDIC05RC76EARPS.X50VFN6L2OP::D+62NDJ8/SX3J %0%T7WP4YEP.PHA*4QH99XKN/Q7Y35NATL4WC76QC1ZT$RU/.N4WE$INCHTC2UD/EF*0X9V4O7JZRHECAPCY5FATVS8J2998NR3ZHD-OC%MDP3L-KY9VXAEYKTY:PPFGA+2VEN*G9CWNYH98OCR0U68CPPAIQLNZ647G/RBV$7GIFY TA*AK/U/RL68HS4UQ:BJ$7DU4N2P:8QBVP6W1O$71AW7OU2CEX4WL2G-XR/-V-%NP3A*N5-3CUOF0RVSRKM2G7M18KP"
        let base45Decoded = (try? base45Encoder.decode(qrCodeString)) ?? []

        return decompress(Data(base45Decoded)) ?? Data()
    }

    func decompress(_ data: Data) -> Data? {
        let size = 8_000_000
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: size)
        let result = data.subdata(in: 2 ..< data.count).withUnsafeBytes ({
            let read = compression_decode_buffer(buffer, size, $0.baseAddress!.bindMemory(to: UInt8.self, capacity: 1),
                                                 data.count - 2, nil, COMPRESSION_ZLIB)
            return Data(bytes: buffer, count:read)
        }) as Data
        buffer.deallocate()
        return result
    }
}
