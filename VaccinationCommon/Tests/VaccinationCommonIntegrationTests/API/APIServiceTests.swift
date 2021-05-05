//
//  APIServiceTests.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

import Foundation
import XCTest
import SwiftCBOR
import Compression
@testable import VaccinationCommon

class APIServiceTests: XCTestCase {
    func testReissue() throws {
        let exp = expectation(description: "request")

        let payload = """
HC1:6BFOXN*TS0BI$ZD4N9:9S6RCVN5+O30K3/XIV0W23NTDEXWK G2EP4J0BGJLOFJEIKVGAE%9ETMSA3/-2E%5VR5VVBJZILDBZ8D%JTQOL0EC7KD/ZL/8D:8DQVDLED0AC2AU/B2/+3HN2HPCT12IID*2T$/TVPTM*SQYDLADYR3JZIM-1U96UX4795L*KDYPWGO+9AKCO.BHOH63K5 *JAYUQJAGPENXUJRHQJA5G6VOE:OQPAU:IAJ0AZZ0OWCR/C+T4D-4HRVUMNMD3323R1392VC-4A+2XEN QT QTHC31M3+E3CP456L X4CZKHKB-43:C3J:R90JK.A5*G%DBZI9$JAQJKKIJX2MM+GWHKSKE MCAOI8%MQQK8+S4-R:KIIX0VJA$:O3HH:EF9NT6D7.Z8OMR-C137HZW2$XK6AL4%IYT0BUF1MFXZG$IV6$0+BN$MVYWV9Y4KCT7-S$ 0GKFCTR0KV4$0RCNV7J$%25I3HC3X83P47YOR40F80U8EHL%BP0CC9R$SEN59KYL 2O1/7*HVNY6:W0..DXJ5YKV4/J/JVZPRD*S0ZV+IR5H7*QS7%JX7HU0PA0PLY705JM/RA73CE3FBI
"""

        let sut = APIService()
        sut.reissue(payload).done({ result in

            if result.isEmpty {
                XCTFail("Result should not be empty")
            }

            // Parse and validate issued validation certificate
            let result = result.stripPrefix()
            let base45Decoded = try Base45Encoder().decode(result)
            guard let decompressedPayload = Compression.decompress(Data(base45Decoded)) else {
                XCTFail("Could not decompress QR Code data")
                return
            }
            let cose1SignEncoder = CoseSign1Parser()
            let cosePayload = try cose1SignEncoder.parse(decompressedPayload)
            let cborDecodedPayload = try CBOR.decode(cosePayload?.payload ?? [])
            let certificateJson = cose1SignEncoder.map(cborObject: cborDecodedPayload)
            let jsonData = try JSONSerialization.data(withJSONObject: certificateJson as Any)
            let sut = try JSONDecoder().decode(CBORWebToken.self, from: jsonData)
            XCTAssertEqual(sut.iss, "DE")

        }).catch({ error in
            XCTFail(error.localizedDescription)
        }).finally {
            exp.fulfill()
        }

        wait(for: [exp], timeout: 10)
    }

    func testReissueFailsWithInvalidData() throws {
        let exp = expectation(description: "request")

        let payload = "6BFOXN*TS0BI$ZD4N9:9S6RCVN5+O30K3/XIV0W23NTDEWSCBVUN$K%OKSQ1C%OE Q$M8XL9PI0IL0N$K8WI674LTSL1E.G0D0HT0HB2PG580RE919W2D/PGLL16DH0A9YHPQ32Y18:FPFAEV358N2EISP+PGUST*QME1W9L $N3-Q4-R2*N.SST*Q9+PFVBF%M RFUS2CPACEG:A3AGJLC1/.9H7U.A5MIH$JL07UPNTCD1%48VINK+MWV4S96UZ6IQ5OA78L6XHMOL638M:Y8LC9NDA3LD.N99FE1KCWLDU*GSHGHD6YW407A0LLKMVIILU01*:K*S2F8LO*4LTAAQ7SZVU*0BC7ZR8X6DAZK-.AF+2+M719TC+GL%4YBD-$SY6T80LO*4KWI7*KB:SMVCZFCWGDE58O5LL.4 QTV*CX.4HK0+$SE7L423423DG3423F0D.$SERGP/I3%17/UC/VY$N4QKEP4ODRFRMZNK6CIJJKHHGWC8IXO%*J LEUUA2/P%EA+T6Z9OOWM 1TZPS$4IXI9ESHX2CWY7+RMV2J8*BZ G3/3ZPC.8M*QEWTU0CHWZ3B.CU$BCVM$EW1.5WZF5EAV50WX0IRK"

        let sut = APIService()
        sut.reissue(payload).done({ result in
            XCTFail("Reissue should fail with invalid data")
        }).catch({ error in
            XCTAssertEqual(error.localizedDescription, "UnexpectedError")
            // TODO add custom errors for API
//            XCTAssertEqual(error.localizedDescription, "Sorry, the incoming cose object is invalid.")
        }).finally {
            exp.fulfill()
        }

        wait(for: [exp], timeout: 10)
    }
}
