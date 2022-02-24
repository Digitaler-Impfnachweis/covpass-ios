//
//  CertificateReissueRepositoryTests.swift
//  
//
//  Created by Thomas Kuleßa on 21.02.22.
//

@testable import CovPassCommon
import XCTest

class CertificateReissueRepositoryTests: XCTestCase {
    var sut: CertificateReissueRepository!
    var urlSession: CertificateReissueURLSessionMock!

    override func setUpWithError() throws {
        urlSession = CertificateReissueURLSessionMock()
        let url = try XCTUnwrap(URL(string: "http://localhost"))
        sut = .init(
            baseURL: url,
            jsonDecoder: JSONDecoder(),
            jsonEncoder: JSONEncoder(),
            urlSession: urlSession
        )
    }

    override func tearDownWithError() throws {
        sut = nil
        urlSession = nil
    }

    func testReissue_returned_data_has_wrong_format() {
        // Given
        let cborWebToken = ""
        let expectation = XCTestExpectation()

        // When
        sut.reissue([cborWebToken])
            .done { _ in
                XCTFail("Must not succeed.")
            }
            .catch { error in
                guard let certificateReissueError = error as? CertificateReissueError else {
                    XCTFail("Wrong error: \(error)")
                    return
                }
                switch certificateReissueError {
                case .decoder:
                    break
                default:
                    XCTFail("Wrong error: \(certificateReissueError)")
                }
                expectation.fulfill()
            }

        // Then
        wait(for: [expectation], timeout: 200)
    }

    func testReissue_http_error() {
        // Given
        let cborWebToken = ""
        let expectation = XCTestExpectation()
        let expectedStatusCode = 542
        urlSession.error = CertificateReissueError.http(expectedStatusCode)

        // When
        sut.reissue([cborWebToken])
            .done { _ in
                XCTFail("Must not succeed.")
            }
            .catch { error in
                guard let certificateReissueError = error as? CertificateReissueError else {
                    XCTFail("Wrong error: \(error)")
                    return
                }
                switch certificateReissueError {
                case let .http(statusCode):
                    XCTAssertEqual(statusCode, expectedStatusCode)
                default:
                    XCTFail("Wrong error: \(certificateReissueError)")
                }
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
        urlSession.data = responseData
    }

    func testReissue_success() throws {
        // Given
        let responseCBORWebTokenString = qrCodeData
        let expectation = XCTestExpectation()
        try prepareURLSession(with: responseCBORWebTokenString)

        // When
        sut.reissue([responseCBORWebTokenString])
            .done { certificateStrings in
                guard let data = self.urlSession.receivedHTTPRequest?.httpBody,
                let requestBody = try? JSONDecoder().decode(CertificateReissueRequestBody.self, from: data) else { return }
                XCTAssertTrue(requestBody.certificates[0].starts(with: "HC1:"))
                XCTAssertEqual(certificateStrings.count, 1)
                guard let certificateString = certificateStrings.first else { return }
                XCTAssertEqual(certificateString, responseCBORWebTokenString)
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

private let qrCodeData = "HC1:6BFOXN*TS0BI$ZD4N9:9S6RCVN5+O30K3/XIV0W23NTDEMWK4MI6UOS03CR83KLBKAVN74.CL91/8K6%KEG3983NS9SVBHABVCNN95SWMPHQUHQN%A400H%UBT16Y51Y9AT1:+P6YBKD0:XB7NGJQOIS7I$H%T5+XO8YJMVHBZJF 9NSG:PICIG%*47%S%*48YIZ73423ZQT-EJDG3XW44$22CLY.IE.KD+2H0D3ZCU7JI$2K3JQH5-Y3$PA$HSCHBI I7995R5ZFQETU 9R*PP:+P*.1D9RYO05QD/8D3FC:XIBEIVG395EP1E+WEDJL8FF3DE0OA0D9E2LBHHNHL$EQ+-CVYCMBB:AV5AL5:4A93MOJLWT.C3FDA.-B97U: KMZNKASADIMKN2GFLF9$HF.3O.X21FDLW4L4OVIOE1M24OR:FTNP8EFVMP9/HWKP/HLIJL8JF8JF172OTTHO9YW2E6LS7WGYNDDSHRSFXT*LMK8P*G8QWD8%P%5GPPMEVMTHDBESW2L.TN8BBBDR9+JLDR/1JGIF8BS0IKT8LB1T7WLA:FI%JI50H:EK1"
