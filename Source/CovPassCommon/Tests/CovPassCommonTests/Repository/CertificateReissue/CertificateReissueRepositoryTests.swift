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
        let certificate = DigitalGreenCertificate.mock()
        let expectation = XCTestExpectation()

        // When
        sut.reissue([certificate])
            .done { certificates in
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
        let certificate = DigitalGreenCertificate.mock()
        let expectation = XCTestExpectation()
        let expectedStatusCode = 542
        urlSession.error = CertificateReissueError.http(expectedStatusCode)

        // When
        sut.reissue([certificate])
            .done { certificates in
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

    func testReissue_response_base_45_decoding_fails() throws {
        // Given
        let responseCertificate = "UNCOMPRESSED NON BASE45 STRING"
        let certificate = DigitalGreenCertificate.mock()
        let expectation = XCTestExpectation()
        try prepareURLSession(with: responseCertificate)

        // When
        sut.reissue([certificate])
            .done { certificates in
                XCTFail("Must not succeed.")
            }
            .catch { error in
                XCTAssertTrue(error is Base45CodingError)
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

    func testReissue_response_uncompression_fails() throws {
        // Given
        let data = try XCTUnwrap("UNCOMPRESSED STRING".data(using: .ascii))
        let responseCertificate = Base45Coder.encode([UInt8](data))
        let certificate = DigitalGreenCertificate.mock()
        let expectation = XCTestExpectation()
        try prepareURLSession(with: responseCertificate)

        // When
        sut.reissue([certificate])
            .done { certificates in
                XCTFail("Must not succeed.")
            }
            .catch { error in
                XCTAssertTrue(error is Compression.Error)
                expectation.fulfill()
            }

        // Then
        wait(for: [expectation], timeout: 2)
    }

    func testReissue_success() throws {
        // Given
        let responseDgc = DigitalGreenCertificate.mock()
        let data = try XCTUnwrap(JSONEncoder().encode(responseDgc))
        let compressedData = try XCTUnwrap(data.compress(withAlgorithm: .zlib))
        let responseCertificate = Base45Coder.encode([UInt8](compressedData))
        let certificate = DigitalGreenCertificate.mock()
        let expectation = XCTestExpectation()
        try prepareURLSession(with: responseCertificate)

        // When
        sut.reissue([certificate])
            .done { certificates in
                guard let data = self.urlSession.receivedHTTPRequest?.httpBody,
                let requestBody = try? JSONDecoder().decode(CertificateReissueRequestBody.self, from: data) else { return }
                XCTAssertTrue(requestBody.certificates[0].starts(with: "HC1:"))
                XCTAssertEqual(certificates.count, 1)
                guard let certificate = certificates.first else { return }
                XCTAssertEqual(certificate, responseDgc)
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
