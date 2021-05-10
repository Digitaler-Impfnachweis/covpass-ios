//
//  APIServiceTests.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

import Compression
import Foundation
import SwiftCBOR
import XCTest
@testable import VaccinationCommon

class APIServiceTests: XCTestCase {

    var sut: APIService!

    override func setUp() {
        super.setUp()
        sut = APIService(
            sessionDelegate: APIServiceDelegate(
                certUrl: Bundle.module.url(forResource: "rsa-certify.demo.ubirch.com", withExtension: "der")!
            ),
            url: "https://api.recertify.demo.ubirch.com/api/certify/v2/reissue/cbor"
        )
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func testReissue() throws {
        let exp = expectation(description: "request")

        let payload = "HC1:6BFOXN*TS0BI$ZD4N9:9S6RCVN5+O30K3/XIV0W23NTDE$VK G2EP4J0B3KL6QM5/OVGA/MAT%ISA3/-2E%5VR5VVBJZILDBZ8D%JTQOLC8CZ8DVCK/8D:8DQVDLED0AC-BU6SS-.DUBDNU347D8MS$ESFHDO8TF724QSHA2YR3JZIM-1U96UX4795L*KDYPWGO+9A*DOPCRFE4IWM:J8QHL9/5.+M1:6G16PCNQ+MLTMU0BR3UR:J.X0A%QXBKQ+8E/C5LG/69+FEKHG4.C/.DV2MGDIE-5QHCYQCJB4IE9WT0K3M9UVZSVK78Y9J8.P++9-G9+E93ZM$96TV6KJ73T59YLQM14+OP$I/XK$M8AO96YBDAKZ%P WUQRELS4J1T7OFKCT6:I /K/*KRZ43R4+*431TVZK WVR*GNS42J0+-9*+7E3KF%CD 810H% 0NY0H$1AVL9%7L26Y1NZ1WNZBPCG*7L%5G.%M/4GNIRDBE6J7DFUPSKX.MLEF8/72SEPKD++I*5FMHD*ZBJDBFKEG2GXTL6%7K7GK7QQ1C3H0A/LGIH"

        sut.reissue(payload).done { result in

            if result.isEmpty {
                XCTFail("Result should not be empty")
            }

            // Parse and validate issued validation certificate
            let result = result.stripPrefix()
            let base45Decoded = try Base45Coder().decode(result)
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
            exp.fulfill()

        }.catch { error in
            XCTFail(error.localizedDescription)
        }

        wait(for: [exp], timeout: 10)
    }

    func testReissueFailsWithInvalidData() throws {
        let exp = expectation(description: "request")

        let payload = "6BFOXN*TS0BI$ZD4N9:9S6RCVN5+O30K3/XIV0W23NTDEWSCBVUN$K%OKSQ1C%OE Q$M8XL9PI0IL0N$K8WI674LTSL1E.G0D0HT0HB2PG580RE919W2D/PGLL16DH0A9YHPQ32Y18:FPFAEV358N2EISP+PGUST*QME1W9L $N3-Q4-R2*N.SST*Q9+PFVBF%M RFUS2CPACEG:A3AGJLC1/.9H7U.A5MIH$JL07UPNTCD1%48VINK+MWV4S96UZ6IQ5OA78L6XHMOL638M:Y8LC9NDA3LD.N99FE1KCWLDU*GSHGHD6YW407A0LLKMVIILU01*:K*S2F8LO*4LTAAQ7SZVU*0BC7ZR8X6DAZK-.AF+2+M719TC+GL%4YBD-$SY6T80LO*4KWI7*KB:SMVCZFCWGDE58O5LL.4 QTV*CX.4HK0+$SE7L423423DG3423F0D.$SERGP/I3%17/UC/VY$N4QKEP4ODRFRMZNK6CIJJKHHGWC8IXO%*J LEUUA2/P%EA+T6Z9OOWM 1TZPS$4IXI9ESHX2CWY7+RMV2J8*BZ G3/3ZPC.8M*QEWTU0CHWZ3B.CU$BCVM$EW1.5WZF5EAV50WX0IRK"

        sut.reissue(payload).done { _ in
            XCTFail("Reissue should fail with invalid data")
        }.catch { error in
            XCTAssertEqual(error.localizedDescription, APIError.invalidReponse.localizedDescription)
            exp.fulfill()
            // TODO: add custom errors for API
//            XCTAssertEqual(error.localizedDescription, "Sorry, the incoming cose object is invalid.")
        }

        wait(for: [exp], timeout: 10)
    }

    func testReissueFailsWithInvalidCert() {
        let exp = expectation(description: "request")

        let payload = "6BFOXN*TS0BI$ZD4N9:9S6RCVN5+O30K3/XIV0W23NTDEWSCBVUN$K%OKSQ1C%OE Q$M8XL9PI0IL0N$K8WI674LTSL1E.G0D0HT0HB2PG580RE919W2D/PGLL16DH0A9YHPQ32Y18:FPFAEV358N2EISP+PGUST*QME1W9L $N3-Q4-R2*N.SST*Q9+PFVBF%M RFUS2CPACEG:A3AGJLC1/.9H7U.A5MIH$JL07UPNTCD1%48VINK+MWV4S96UZ6IQ5OA78L6XHMOL638M:Y8LC9NDA3LD.N99FE1KCWLDU*GSHGHD6YW407A0LLKMVIILU01*:K*S2F8LO*4LTAAQ7SZVU*0BC7ZR8X6DAZK-.AF+2+M719TC+GL%4YBD-$SY6T80LO*4KWI7*KB:SMVCZFCWGDE58O5LL.4 QTV*CX.4HK0+$SE7L423423DG3423F0D.$SERGP/I3%17/UC/VY$N4QKEP4ODRFRMZNK6CIJJKHHGWC8IXO%*J LEUUA2/P%EA+T6Z9OOWM 1TZPS$4IXI9ESHX2CWY7+RMV2J8*BZ G3/3ZPC.8M*QEWTU0CHWZ3B.CU$BCVM$EW1.5WZF5EAV50WX0IRK"

        let sut = APIService(
            sessionDelegate: APIServiceDelegate(certUrl: Bundle.module.url(forResource: "no-certify.demo.ubirch.com", withExtension: "der")!),
            url: "https://api.recertify.demo.ubirch.com/api/certify/v2/reissue/cbor"
        )
        sut.reissue(payload).done { _ in
            XCTFail("Reissue should fail with cancelled")
        }.catch { error in
            XCTAssertEqual(error.localizedDescription, APIError.requestCancelled.localizedDescription)
            exp.fulfill()
        }

        wait(for: [exp], timeout: 10)
    }
}
