//
//  CertificateReissueRepositoryTests.swift
//  
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassCommon
import XCTest

class CertificateReissueRepositoryTests: XCTestCase {
    private var sut: CertificateReissueRepository!
    private var httpClient: HTTPClientMock!

    override func setUpWithError() throws {
        httpClient = HTTPClientMock()
        let url = try XCTUnwrap(URL(string: "http://localhost"))
        let trustListURL = Bundle.commonBundle.url(
            forResource: "dsc",
            withExtension: "json"
        )!
        let jsonDecoder = JSONDecoder()
        let trustListData = try Data(contentsOf: trustListURL)
        let trustList = try jsonDecoder.decode(TrustList.self, from: trustListData)
        let coseSign1MessageConverter = CoseSign1MessageConverter(
            jsonDecoder: jsonDecoder,
            trustList: trustList,
            verifyExpiration: true
        )
        sut = .init(
            baseURL: url,
            jsonDecoder: jsonDecoder,
            jsonEncoder: JSONEncoder(),
            httpClient: httpClient,
            coseSign1MessageConverter: coseSign1MessageConverter
        )
    }

    override func tearDownWithError() throws {
        sut = nil
        httpClient = nil
    }

    func testRenew_returned_data_has_wrong_format() {
        // Given
        let cborWebToken = CBORWebToken.mockVaccinationCertificate.extended()
        let expectation = XCTestExpectation()

        // When
        sut.renew([cborWebToken])
            .catch { error in
                guard error as? CertificateReissueRepositoryFallbackError != nil else {
                    XCTFail("Wrong error: \(error)")
                    return
                }
                expectation.fulfill()
            }

        // Then
        wait(for: [expectation], timeout: 2)
    }

    func testRenew_http_error() throws {
        // Given
        let cborWebToken = CBORWebToken.mockVaccinationCertificate.extended()
        let expectation = XCTestExpectation()
        let errorResponse = CertificateReissueResponseError(
            error: "RXXX",
            message: "MESSAGE"
        )
        let data = try JSONEncoder().encode(errorResponse)
        httpClient.error = HTTPClientError.http(
            542,
            data: data
        )

        // When
        sut.renew([cborWebToken])
            .catch { error in
                guard let certificateReissueError = error as? CertificateReissueRepositoryError else {
                    XCTFail("Wrong error: \(error)")
                    return
                }
                XCTAssertEqual(certificateReissueError.errorID, errorResponse.error)
                XCTAssertEqual(certificateReissueError.message, errorResponse.message)
                expectation.fulfill()
            }

        // Then
        wait(for: [expectation], timeout: 2)
    }

    func testRenew_http_error_no_response_body() throws {
        // Given
        let cborWebToken = CBORWebToken.mockVaccinationCertificate.extended()
        let expectation = XCTestExpectation()
        let expectedError = CertificateReissueRepositoryFallbackError()
        httpClient.error = HTTPClientError.http(476, data: Data())

        // When
        sut.renew([cborWebToken])
            .catch { error in
                guard let certificateReissueError = error as? CertificateReissueRepositoryError else {
                    XCTFail("Wrong error: \(error)")
                    return
                }
                XCTAssertEqual(certificateReissueError, expectedError)
                expectation.fulfill()
            }

        // Then
        wait(for: [expectation], timeout: 2)
    }

    func testRenew_http_error_500_no_response_body() throws {
        // Given
        let cborWebToken = CBORWebToken.mockVaccinationCertificate.extended()
        let expectation = XCTestExpectation()
        let expectedError = CertificateReissueRepositoryError("R500", message: nil)
        httpClient.error = HTTPClientError.http(500, data: Data())

        // When
        sut.renew([cborWebToken])
            .catch { error in
                guard let certificateReissueError = error as? CertificateReissueRepositoryError else {
                    XCTFail("Wrong error: \(error)")
                    return
                }
                XCTAssertEqual(certificateReissueError, expectedError)
                expectation.fulfill()
            }

        // Then
        wait(for: [expectation], timeout: 2)
    }

    func testRenew_http_error_429_no_response_body() throws {
        // Given
        let cborWebToken = CBORWebToken.mockVaccinationCertificate.extended()
        let expectation = XCTestExpectation()
        let expectedError = CertificateReissueRepositoryError("R429", message: nil)
        httpClient.error = HTTPClientError.http(429, data: Data())

        // When
        sut.renew([cborWebToken])
            .catch { error in
                guard let certificateReissueError = error as? CertificateReissueRepositoryError else {
                    XCTFail("Wrong error: \(error)")
                    return
                }
                XCTAssertEqual(certificateReissueError, expectedError)
                expectation.fulfill()
            }

        // Then
        wait(for: [expectation], timeout: 2)
    }

    func prepareURLSession(with certificate: String) throws {
        let response: [CertificateReissueResponse] = [
            .init(
                certificate: certificate,
                relations: []
            )
        ]
        let responseData = try JSONEncoder().encode(response)
        httpClient.response = .init(
            httpURLResponse: HTTPURLResponse(),
            data: responseData
        )
    }

    func testRenew_success() throws {
        // Given
        let expectation = XCTestExpectation()
        try prepareURLSession(with: qrCodeData)

        // When
        sut.renew([ExtendedCBORWebToken(vaccinationCertificate: .mockVaccinationCertificate,
                                          vaccinationQRCodeData: qrCodeData)])
            .done { webTokens in
                guard let data = self.httpClient.receivedHTTPRequest?.httpBody,
                      let requestBody = try? JSONDecoder().decode(CertificateReissueRequestBody.self, from: data) else { return }
                XCTAssertTrue(requestBody.certificates[0].starts(with: "HC1:"))
                XCTAssertEqual(requestBody.action, .renew)
                XCTAssertEqual(webTokens.count, 1)
                guard let certificateString = webTokens.first?.vaccinationQRCodeData else { return }
                XCTAssertEqual(certificateString, qrCodeData)
                expectation.fulfill()
            }
            .catch { error in
                XCTFail("Must not fail with: \(error)")
            }

        // Then
        wait(for: [expectation], timeout: 2)
    }

    func testExtend_returned_data_has_wrong_format() {
        // Given
        let cborWebToken = CBORWebToken.mockVaccinationCertificate.extended()
        let expectation = XCTestExpectation()

        // When
        sut.extend([cborWebToken])
            .catch { error in
                guard error as? CertificateReissueRepositoryFallbackError != nil else {
                    XCTFail("Wrong error: \(error)")
                    return
                }
                expectation.fulfill()
            }

        // Then
        wait(for: [expectation], timeout: 2)
    }

    func testExtend_http_error() throws {
        // Given
        let cborWebToken = CBORWebToken.mockVaccinationCertificate.extended()
        let expectation = XCTestExpectation()
        let errorResponse = CertificateReissueResponseError(
            error: "RXXX",
            message: "MESSAGE"
        )
        let data = try JSONEncoder().encode(errorResponse)
        httpClient.error = HTTPClientError.http(
            542,
            data: data
        )

        // When
        sut.extend([cborWebToken])
            .catch { error in
                guard let certificateReissueError = error as? CertificateReissueRepositoryError else {
                    XCTFail("Wrong error: \(error)")
                    return
                }
                XCTAssertEqual(certificateReissueError.errorID, errorResponse.error)
                XCTAssertEqual(certificateReissueError.message, errorResponse.message)
                expectation.fulfill()
            }

        // Then
        wait(for: [expectation], timeout: 2)
    }

    func testExtend_http_error_no_response_body() throws {
        // Given
        let cborWebToken = CBORWebToken.mockVaccinationCertificate.extended()
        let expectation = XCTestExpectation()
        let expectedError = CertificateReissueRepositoryFallbackError()
        httpClient.error = HTTPClientError.http(476, data: Data())

        // When
        sut.extend([cborWebToken])
            .catch { error in
                guard let certificateReissueError = error as? CertificateReissueRepositoryError else {
                    XCTFail("Wrong error: \(error)")
                    return
                }
                XCTAssertEqual(certificateReissueError, expectedError)
                expectation.fulfill()
            }

        // Then
        wait(for: [expectation], timeout: 2)
    }

    func testExtend_http_error_500_no_response_body() throws {
        // Given
        let cborWebToken = CBORWebToken.mockVaccinationCertificate.extended()
        let expectation = XCTestExpectation()
        let expectedError = CertificateReissueRepositoryError("R500", message: nil)
        httpClient.error = HTTPClientError.http(500, data: Data())

        // When
        sut.extend([cborWebToken])
            .catch { error in
                guard let certificateReissueError = error as? CertificateReissueRepositoryError else {
                    XCTFail("Wrong error: \(error)")
                    return
                }
                XCTAssertEqual(certificateReissueError, expectedError)
                expectation.fulfill()
            }

        // Then
        wait(for: [expectation], timeout: 2)
    }

    func testExtend_http_error_429_no_response_body() throws {
        // Given
        let cborWebToken = CBORWebToken.mockVaccinationCertificate.extended()
        let expectation = XCTestExpectation()
        let expectedError = CertificateReissueRepositoryError("R429", message: nil)
        httpClient.error = HTTPClientError.http(429, data: Data())

        // When
        sut.extend([cborWebToken])
            .catch { error in
                guard let certificateReissueError = error as? CertificateReissueRepositoryError else {
                    XCTFail("Wrong error: \(error)")
                    return
                }
                XCTAssertEqual(certificateReissueError, expectedError)
                expectation.fulfill()
            }

        // Then
        wait(for: [expectation], timeout: 2)
    }

    func testExtend_success() throws {
        // Given
        let expectation = XCTestExpectation()
        try prepareURLSession(with: qrCodeData)

        // When
        sut.extend([ExtendedCBORWebToken(vaccinationCertificate: .mockVaccinationCertificate,
                                          vaccinationQRCodeData: qrCodeData)])
            .done { webTokens in
                guard let data = self.httpClient.receivedHTTPRequest?.httpBody,
                      let requestBody = try? JSONDecoder().decode(CertificateReissueRequestBody.self, from: data) else { return }
                XCTAssertTrue(requestBody.certificates[0].starts(with: "HC1:"))
                XCTAssertEqual(requestBody.action, .extend)
                XCTAssertEqual(webTokens.count, 1)
                guard let certificateString = webTokens.first?.vaccinationQRCodeData else { return }
                XCTAssertEqual(certificateString, qrCodeData)
                expectation.fulfill()
            }
            .catch { error in
                XCTFail("Must not fail with: \(error)")
            }

        // Then
        wait(for: [expectation], timeout: 2)
    }
}

private extension DigitalGreenCertificate {
    static func mock() -> DigitalGreenCertificate {
        .init(
            nam: .init(gn: nil, fn: nil, gnt: nil, fnt: "MUSTERMANN"),
            dob: nil,
            dobString: nil,
            v: [
                .init(
                    tg: "",
                    vp: "",
                    mp: "",
                    ma: "",
                    dn: 1,
                    sd: 2,
                    dt: Date(timeIntervalSinceReferenceDate: 0),
                    co: "",
                    is: "",
                    ci: ""
                )
            ],
            t: nil,
            r: nil,
            ver: "1.0"
        )
    }
}

private extension CertificateReissueResponse {
    static func mock() -> CertificateReissueResponse {
        .init(
            certificate: CertificateMock.validCertificate,
            relations: []
        )
    }
}

private let qrCodeData = "HC1:b'6BFOXN%TSMAHN-HWWK2RL99TEZP3Z9M52O651WG%MPG*ICG5*KMJT7+P66H0*VSZ C1FFF/8X*G-O9 WUQRELS4 CT0Z0:Z23-CY/K5+C$/IU7JB+2D-4Q/S8ALD-IKZ0IZ0%JF6AL**INOV6$0+BN$MVYWV9Y4.$S6ZC0JBV63KD38D0MJC7ZS2%KYZPJWLK34JWLG56H0API0Z.2G F.J2CJ0R$F:L6FI2 L6GI1:PC27JSBCVAE%7E0L24GSTQHG0799QD0AU3ETI08N2/HS$*STAK4SI4UU4SI.J9WVHWVH+ZEJFGTRJ3ZC54JS/S7*K .I8OF7:4OHT-3TB6JS1J6:IR/S09T./0LWTKD3323/I0SRJB/S7-SN2H N37J3JFTULJBGJ8X2.36D-I/2DBAJDAJCNB-43 X4VV2 73-E3ND3DAJ-43O*47*KB*KYQTKWT4S8M$MO7CVDBX+VTJM6:NLALKMF6.EZTN-+LQJ583LGAPLE4*HUI.S% N1SB5:P+3GACTEO59XH.M6ZXMAGW78LRB7EHHG P-:Q070J:9M10/A5.4'"
