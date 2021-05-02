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

// !IMPORTANT! THIS IS AN INTEGRATION TEST AND RUNS AGAINST THE REAL BACKEND
class APIServiceTests: XCTestCase {
    func testReissue() throws {
        let exp = expectation(description: "request")

        let payload = """
6BFWZ8VIMDWR-53HT0+M981HE-IQ%8/MLK3OK$JZXDCGE+014R2NJADEJXDTJ7VL
GVX0SB 9312D7155F2G70VAIFT4ILV:Q++L6%2NNKAA9-K56EOG:6ASTGBSDAOY4
FI/AXBJ PN%%Q LUGEVRDDH4A*5KE6O15OO8LPMNC29JDFGZH/QAHKQ2LTXXSDMP
JH4LPLK.PYYRZPR-J3PRBI*HO.NGDRI*EMJCT-J:2D8WAYHOM84G$7S67S44Z64W
D3J34HRIZ60U9BHN2:GG$33GJAY7CN%K22BVZGI30/73X6613TK-A4W4HB8W$2 D
OHTAZ$PJI8K 12620OL-98V.6TNADD54T8RKK.FISK6/69HGT698+VG0IEIK7CBK
PICPHK5.8U27VG1S6B*HDM:A%IGWTC/-T$VE62H19OVT9ND4H7E6JKBOU9ED9.3P
DKV$AFGW-AV3OOE6K$$IE525I00IAEQ06P3LFGL9C*IHT*K9XB7*F+TQD9UCGVFV
TU9KT1P3COHK7-8TR%T$4WS6RDDWYC7:TDHDTI8T8X20ZST9W6.VQE9Y0GPDL6-3
7+8N+0Q1LLZBCA9OC0O7820
"""

        let sut = APIService()
        sut.reissue(payload).done({ result in

            if result.isEmpty {
                XCTFail("Result should not be empty")
            }

            // Parse and validate issued validation certificate
            let cose1SignEncoder = CoseSign1Parser()
            let cosePayload = try cose1SignEncoder.parse(result.data(using: .utf8) ?? Data())
            let cborDecodedPayload = try CBOR.decode(cosePayload?.payload ?? [])
            let certificateJson = cose1SignEncoder.map(cborObject: cborDecodedPayload)
            let jsonData = try JSONSerialization.data(withJSONObject: certificateJson as Any)
            let sut = try JSONDecoder().decode(ValidationCertificate.self, from: jsonData)
            XCTAssertEqual(sut.id, "")

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
