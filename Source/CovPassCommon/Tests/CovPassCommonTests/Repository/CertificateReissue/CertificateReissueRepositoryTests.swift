//
//  CertificateReissueRepositoryTests.swift
//  
//
//  Created by Thomas Kuleßa on 21.02.22.
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
        sut = .init(
            baseURL: url,
            jsonDecoder: jsonDecoder,
            jsonEncoder: JSONEncoder(),
            trustList: trustList,
            httpClient: httpClient
        )
    }

    override func tearDownWithError() throws {
        sut = nil
        httpClient = nil
    }

    func testReissue_returned_data_has_wrong_format() {
        // Given
        let cborWebToken = CBORWebToken.mockVaccinationCertificate.extended()
        let expectation = XCTestExpectation()

        // When
        sut.reissue([cborWebToken])
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

    func testReissue_http_error() throws {
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
        sut.reissue([cborWebToken])
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

    func testReissue_http_error_no_response_body() throws {
        // Given
        let cborWebToken = CBORWebToken.mockVaccinationCertificate.extended()
        let expectation = XCTestExpectation()
        let expectedError = CertificateReissueRepositoryFallbackError()
        httpClient.error = HTTPClientError.http(476, data: Data())

        // When
        sut.reissue([cborWebToken])
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

    func testReissue_http_error_500_no_response_body() throws {
        // Given
        let cborWebToken = CBORWebToken.mockVaccinationCertificate.extended()
        let expectation = XCTestExpectation()
        let expectedError = CertificateReissueRepositoryError("R500", message: nil)
        httpClient.error = HTTPClientError.http(500, data: Data())

        // When
        sut.reissue([cborWebToken])
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

    func testReissue_http_error_429_no_response_body() throws {
        // Given
        let cborWebToken = CBORWebToken.mockVaccinationCertificate.extended()
        let expectation = XCTestExpectation()
        let expectedError = CertificateReissueRepositoryError("R429", message: nil)
        httpClient.error = HTTPClientError.http(429, data: Data())

        // When
        sut.reissue([cborWebToken])
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
        httpClient.data = responseData
    }

    func testReissue_success() throws {
        // Given
        let expectation = XCTestExpectation()
        try prepareURLSession(with: qrCodeData)

        // When
        sut.reissue([ExtendedCBORWebToken(vaccinationCertificate: .mockVaccinationCertificate, vaccinationQRCodeData: qrCodeData)])
            .done { webTokens in
                guard let data = self.httpClient.receivedHTTPRequest?.httpBody,
                      let requestBody = try? JSONDecoder().decode(CertificateReissueRequestBody.self, from: data) else { return }
                XCTAssertTrue(requestBody.certificates[0].starts(with: "HC1:"))
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

private let qrCodeData = "HC1:6BFOXN*TS0BI$ZD-PH-RJ 9M$0W%1Q0IIRF5 43JUB/EBINILC3A4DAJ9AIV.5E/GPWBIMDBDCA6JCFN8GGBYPLR-S E10EQ928GEQW2DVJ5UL8W2B0I1BMA:PCGJ0X3DYNAJQEJ/53OC*I289R73D%5CA10V.27AV43T2%K:XFPIM.A5:S9395*CBVZ0G.8PZ0CWC.XI/VBVGTKOJQMI-ZJYIJGDBQMI.XI+OJ$BIJ9FZHI4RFOA69E4MZ6WP4:/6N9R%EPXCROGO3HOWGOKEQEC5L64HX6IAS3DS2980IQODPUHLW$GAHLW 70SO:GOLIROGO3T59YLLYP-HQLTQ9R0+L69/9L:9GJBV9C1QD1217LPMIH-O92UQME6ZPQSTL*SHOQ13UQ-H6%J62YUYJAHN6XZQ4H9CG0/T7DVBWVH/UIMEGS/4X6G/2264D1-ST*QGTA4W7.Y7N31RO45MBAP6VYIPS5XKJ XBI5H 2S61SB02/35CM7/TTMT8425Z0CZ.A7-U 8MD/R1DTRAOQ7SLJ6E%DCKQJW2BL0YIA0ZCS0G94C.0NX40VFPA2"
