//
//  CoseSign1MessageConverterTests.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassCommon
import XCTest

class CoseSign1MessageConverterTests: XCTestCase {
    private var sut: CoseSign1MessageConverter!

    override func setUpWithError() throws {
        try configureSut()
    }

    private func configureSut(verifyExpiration: Bool = true) throws {
        let trustListURL = Bundle.commonBundle.url(
            forResource: "dsc",
            withExtension: "json"
        )!
        let jsonDecoder = JSONDecoder()
        let trustListData = try Data(contentsOf: trustListURL)
        let trustList = try jsonDecoder.decode(TrustList.self, from: trustListData)
        sut = .init(
            jsonDecoder: jsonDecoder,
            trustList: trustList,
            verifyExpiration: verifyExpiration
        )
    }

    override func tearDownWithError() throws {
        sut = nil
    }

    func testConvert_empty_message() {
        // Given
        let message = ""
        let expectation = XCTestExpectation()

        // When
        sut.convert(message: message)
            .done { _ in
                XCTFail("Must not succeed.")
            }
            .catch { error in
                XCTAssertTrue(error is Compression.Error)
                expectation.fulfill()
            }

        // Then
        wait(for: [expectation], timeout: 1)
    }

    func testConvert_expired_message() {
        // Given
        let message = expiredToken
        let expectation = XCTestExpectation()

        // When
        sut.convert(message: message)
            .done { _ in
                XCTFail("Must not succeed.")
            }
            .catch { error in
                if let error = error as? CertificateError, case .expiredCertifcate = error {
                    expectation.fulfill()
                } else {
                    XCTFail("Wrong error.")
                }
            }

        // Then
        wait(for: [expectation], timeout: 1)
    }

    func testConvert_expired_message_but_dont_verify_it() throws {
        // Given
        let message = expiredToken
        let expectation = XCTestExpectation()
        try configureSut(verifyExpiration: false)

        // When
        sut.convert(message: message)
            .done { _ in
                expectation.fulfill()
            }
            .catch { _ in
                XCTFail("Must not fail.")
            }

        // Then
        wait(for: [expectation], timeout: 1)
    }

    func testConvert_valid_message() {
        // Given
        let message = validToken
        let expectation = XCTestExpectation()

        // When
        sut.convert(message: message)
            .done { _ in
                expectation.fulfill()
            }
            .catch { _ in
                XCTFail("Must not fail.")
            }

        // Then
        wait(for: [expectation], timeout: 1)
    }
}

private let validToken = "HC1:b'6BFOXN%TSMAHN-HWWK2RL99TEZP3Z9M52O651WG%MPG*ICG5*KMJT7+P66H0*VSZ C1FFF/8X*G-O9 WUQRELS4 CT0Z0:Z23-CY/K5+C$/IU7JB+2D-4Q/S8ALD-IKZ0IZ0%JF6AL**INOV6$0+BN$MVYWV9Y4.$S6ZC0JBV63KD38D0MJC7ZS2%KYZPJWLK34JWLG56H0API0Z.2G F.J2CJ0R$F:L6FI2 L6GI1:PC27JSBCVAE%7E0L24GSTQHG0799QD0AU3ETI08N2/HS$*STAK4SI4UU4SI.J9WVHWVH+ZEJFGTRJ3ZC54JS/S7*K .I8OF7:4OHT-3TB6JS1J6:IR/S09T./0LWTKD3323/I0SRJB/S7-SN2H N37J3JFTULJBGJ8X2.36D-I/2DBAJDAJCNB-43 X4VV2 73-E3ND3DAJ-43O*47*KB*KYQTKWT4S8M$MO7CVDBX+VTJM6:NLALKMF6.EZTN-+LQJ583LGAPLE4*HUI.S% N1SB5:P+3GACTEO59XH.M6ZXMAGW78LRB7EHHG P-:Q070J:9M10/A5.4'"

private let expiredToken = "HC1:b'6BFOXN%TSMAHN-HWWK2RL99TEZP3Z9M52M651WG%MPG*ICG5ILM-D43KL *GS%ISA3/-2E%5Q3QR$P*NI92KHG3-8B.CJDZI59JVOBSVBDKB7UJH7J:ZJ83B7I3R632IT ZJ83BG/SOD3CQSD.S/JTM7J5OI9YI:8DHFC%PD121SGH.+H$NI4L6/YL%UG/YL WO*Z7ON15 BZ:U2T93W13:U-.P1Y9$ZPWVHHY1$YBLOG5WOJQOSR92LGRY5X+R W7NZ7T$NQT1F 9NSG:PIKIGEN9UKPH+9WC5ME6WI5RV6FF362KGDBVF2$7K*IB$QKV-J2 JDZT:1BPMIMIA*NI7UJQWT.+S1QDC8CI6CDUAHOJ+PB/VSQOL9DLKWCZ3EBKD/MJZ JFYJ4OIMEDTJCJKDLEDL9CZTAKBI/8D:8DOVD7KDP9CWVBDKBYLDZ4DE1DCOSZJ78.S.YGP33-MUP-NY$8:27P.BE RN OJTKVZRCY18UE*ZNV6U.HM%96/ 9*9HMKA.08U HV%9WJL WOAH4Q7RJEUSK7-:TQ$IJD4-:52.F'"
