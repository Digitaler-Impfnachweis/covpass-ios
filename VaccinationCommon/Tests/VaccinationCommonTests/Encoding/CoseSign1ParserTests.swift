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
        let decompressedPayload = prepareData()
        let coseSign1Message = try! sut.parse(decompressedPayload)

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
        let coseSign1Message = try sut.parse(decompressedPayload)

        guard let message = coseSign1Message else {
            XCTFail("Cose1SignMessage should not be nil")
            return
        }
        let mappedDictionary = sut.map(cborObject: try? CBOR.decode(message.payload))

        XCTAssertEqual(mappedDictionary?["4"] as? UInt64, 1_620_652_117)
        XCTAssertEqual(mappedDictionary?["1"] as? String, "DE")
        XCTAssertEqual(mappedDictionary?["6"] as? UInt64, 1_619_167_131)
    }
}

extension CoseSign1ParserTests {
    func prepareData() -> Data {
        let qrCodeString = "6BFOXN*TS0BI$ZD4N9:9S6RCVN5+O30K3/XIV0W23NTDEXWK G2EP4J0BGJLOFJEIKVGAE%9ETMSA3/-2E%5VR5VVBJZILDBZ8D%JTQOL0EC7KD/ZL/8D:8DQVDLED0AC2AU/B2/+3HN2HPCT12IID*2T$/TVPTM*SQYDLADYR3JZIM-1U96UX4795L*KDYPWGO+9AKCO.BHOH63K5 *JAYUQJAGPENXUJRHQJA5G6VOE:OQPAU:IAJ0AZZ0OWCR/C+T4D-4HRVUMNMD3323R1392VC-4A+2XEN QT QTHC31M3+E3CP456L X4CZKHKB-43:C3J:R90JK.A5*G%DBZI9$JAQJKKIJX2MM+GWHKSKE MCAOI8%MQQK8+S4-R:KIIX0VJA$:O3HH:EF9NT6D7.Z8OMR-C137HZW2$XK6AL4%IYT0BUF1MFXZG$IV6$0+BN$MVYWV9Y4KCT7-S$ 0GKFCTR0KV4$0RCNV7J$%25I3HC3X83P47YOR40F80U8EHL%BP0CC9R$SEN59KYL 2O1/7*HVNY6:W0..DXJ5YKV4/J/JVZPRD*S0ZV+IR5H7*QS7%JX7HU0PA0PLY705JM/RA73CE3FBI"
        let base45Decoded = (try? base45Encoder.decode(qrCodeString)) ?? []
        return Compression.decompress(Data(base45Decoded)) ?? Data()
    }
}
