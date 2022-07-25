//
//  CertificateRevocationHTTPDataSourceTests.swift
//  
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassCommon
import XCTest

class CertificateRevocationHTTPDataSourceTests: XCTestCase {
    private var baseURL: URL!
    private var client: HTTPClientMock!
    private var sut: CertificateRevocationHTTPDataSource!

    override func setUpWithError() throws {
        baseURL = try XCTUnwrap(URL(string: "https://localhost"))
        let base64EncodedCoseMessage = "0oRDoQEmoFhcpklptx1ptx1ptx2hQQoBSGFiY2RlZmdooUEKA0j1xZcMMDnYVKNBCgRBCwFBDAFIjErg7UWLZ/GhQQoCSAeAWyUMdZWEo0EKAkELAkEMAkj1AVmjLYTonaFBCwVYQPvCkhxAu2OpXTWXK5Fwcp5ghZWoquDDxu8ROlouygn6psPRt/AXVD0EBXBCNwqI6mp4ZKzUc2qdygskw9fuwwk="
        let data = try XCTUnwrap(Data(base64Encoded: base64EncodedCoseMessage))
        let response = try XCTUnwrap(
            HTTPURLResponse(
                url: baseURL,
                statusCode: 200,
                httpVersion: nil,
                headerFields: [
                    "Last-Modified": "ABC"
                ]
            )
        )
        client = .init()
        client.response = .mock(httpURLResponse: response, data: data)
        let secKey = try publicKey.secKey()
        sut = .init(baseURL: baseURL, httpClient: client, secKey: secKey)
    }

    override func tearDownWithError() throws {
        baseURL = nil
        client = nil
        sut = nil
    }

    func testGetKIDList_error() {
        // Given
        client.error = NSError(domain: "TEST", code: 0)
        let expectation = XCTestExpectation()

        // When
        sut.getKIDList().catch { _ in expectation.fulfill() }

        // Then
        wait(for: [expectation], timeout: 2)
    }

    func testGetKIDList_response_not_cose() {
        // Given
        client.response = .mock(data: Data([1,2,3]))
        let expectation = XCTestExpectation()

        // When
        sut.getKIDList().catch { _ in expectation.fulfill() }

        // Then
        wait(for: [expectation], timeout: 2)
    }

    func testGetKIDList_success() {
        // Given
        let expectedURL = baseURL.appendingPathComponent("/kid.lst")
        let expectation = XCTestExpectation()

        // When
        sut.getKIDList()
            .done { response in
                XCTAssertEqual(response.lastModified, "ABC")
                expectation.fulfill()
            }
            .cauterize()

        // Then
        wait(for: [expectation], timeout: 2)
        XCTAssertEqual(client.receivedHTTPRequest?.url, expectedURL)
        XCTAssertEqual(client.receivedHTTPRequest?.httpMethod?.uppercased(), "GET")
    }

    func testGetKIDList_response_is_nil() throws {
        // Given
        client.response = .init(
            httpURLResponse: try XCTUnwrap(
                .init(
                    url: FileManager.default.temporaryDirectory,
                    statusCode: HTTPStatusCode.notModified,
                    httpVersion: nil,
                    headerFields: nil
                )
            ),
            data: nil
        )
        let expectation = XCTestExpectation()

        // When
        sut.getKIDList()
            .done { _ in }
            .catch { _ in
                expectation.fulfill()
            }

        // Then
        wait(for: [expectation], timeout: 2)
    }

    func testGetKIDListHttpHeaders_response_data_is_nil() {
        // Given
        client.response = .mock(data: nil)
        let expectation = XCTestExpectation()

        // When
        sut.getKIDList(httpHeaders: [:])
            .done { _ in }
            .catch { _ in
                expectation.fulfill()
            }

        // Then
        wait(for: [expectation], timeout: 2)
    }

    func testGetIndexListKIDHashType_response_is_nil() throws {
        // Given
        client.response = .init(
            httpURLResponse: try XCTUnwrap(
                .init(
                    url: FileManager.default.temporaryDirectory,
                    statusCode: HTTPStatusCode.notModified,
                    httpVersion: nil,
                    headerFields: nil
                )
            ),
            data: nil
        )
        let expectation = XCTestExpectation()

        // When
        sut.getKIDList()
            .done { _ in }
            .catch { _ in
                expectation.fulfill()
            }

        // Then
        wait(for: [expectation], timeout: 2)
    }

    func testGetIndexListHttpHeaders_response_data_is_nil() throws {
        // Given
        client.response = .mock(data: nil)
        let expectation = XCTestExpectation()

        // When
        sut.getIndexList(kid: [1, 2, 3], hashType: .uci, httpHeaders: [:])
            .done { _ in }
            .catch { _ in
                expectation.fulfill()
            }

        // Then
        wait(for: [expectation], timeout: 2)
    }

    func testGetIndexList_response_data_is_nil() throws {
        // Given
        client.response = .mock(data: nil)
        let expectation = XCTestExpectation()

        // When
        sut.getIndexList()
            .done { _ in }
            .catch { _ in
                expectation.fulfill()
            }

        // Then
        wait(for: [expectation], timeout: 2)
    }

    func testGetIndexList_error() {
        // Given
        client.error = NSError(domain: "TEST", code: 0)
        let expectation = XCTestExpectation()

        // When
        sut.getIndexList().catch { _ in expectation.fulfill() }

        // Then
        wait(for: [expectation], timeout: 2)
    }

    func testIndexList_response_not_cose() {
        // Given
        client.response = .mock(data: Data([1,2,3]))
        let expectation = XCTestExpectation()

        // When
        sut.getIndexList().catch { _ in expectation.fulfill() }

        // Then
        wait(for: [expectation], timeout: 2)
    }

    func testGetIndexList_success() {
        // Given
        let expectedURL = baseURL.appendingPathComponent("/index.lst")
        let expectation = XCTestExpectation()

        // When
        sut.getIndexList()
            .done { _ in expectation.fulfill() }
            .cauterize()

        // Then
        wait(for: [expectation], timeout: 2)
        XCTAssertEqual(client.receivedHTTPRequest?.url, expectedURL)
        XCTAssertEqual(client.receivedHTTPRequest?.httpMethod?.uppercased(), "GET")
    }

    func testGetIndexListKIDHashType_error() {
        // Given
        client.error = NSError(domain: "TEST", code: 0)
        let expectation = XCTestExpectation()

        // When
        sut.getIndexList(kid: [0], hashType: .signature).catch { _ in expectation.fulfill() }

        // Then
        wait(for: [expectation], timeout: 2)
    }

    func testGetIndexListKIDHashType_response_not_cose() {
        // Given
        client.response = .mock(data: Data([1,2,3]))
        let expectation = XCTestExpectation()

        // When
        sut.getIndexList(kid: [0], hashType: .uci).catch { _ in expectation.fulfill() }

        // Then
        wait(for: [expectation], timeout: 2)
    }

    func testGetIndexListKIDHashType_success() throws {
        // Given
        let expectedURL = baseURL.appendingPathComponent("/abcd0c/index.lst")
        let expectation = XCTestExpectation()
        let base64EncodedCoseMessage = "0oRDoQEmoFhNpEG0gxpiHKNsAaFBZYIaYhyjbAFB74MaYh3wWQGhQUeCGmId8FkBQaaDGmId8FoBoUG4ghpiHfBaAUHsgxpiHfBbAaFB4YIaYh3wWwFYQF1LhfIKTGtABh+5xmJTtJRhVXoLL6iTpZl9HpJeo2zIoAZX0edzFPT3sijHEfSTUJp4Jil/PZvdH2YKCUlWaYg="
        let data = try XCTUnwrap(Data(base64Encoded: base64EncodedCoseMessage))
        let response = try XCTUnwrap(
            HTTPURLResponse(
                url: baseURL,
                statusCode: 200,
                httpVersion: nil,
                headerFields: [
                    "Last-Modified": "ABC"
                ]
            )
        )
        client.response = .mock(httpURLResponse: response, data: data)

        // When
        sut.getIndexList(kid: [0xab, 0xcd], hashType: .countryCodeUCI)
            .done { response in
                XCTAssertEqual(response.lastModified, "ABC")
                expectation.fulfill()
            }
            .cauterize()

        // Then
        wait(for: [expectation], timeout: 2)
        XCTAssertEqual(client.receivedHTTPRequest?.url, expectedURL)
        XCTAssertEqual(client.receivedHTTPRequest?.httpMethod?.uppercased(), "GET")
    }

    func testHeadIndexListKIDHashType_error() {
        // Given
        client.error = NSError(domain: "TEST", code: 0)
        let expectation = XCTestExpectation()

        // When
        sut.headIndexList(kid: [0], hashType: .signature).catch { _ in expectation.fulfill() }

        // Then
        wait(for: [expectation], timeout: 2)
    }

    func testHeadIndexListKIDHashType_success() {
        // Given
        let expectedURL = baseURL.appendingPathComponent("/abcd0b/index.lst")
        let expectation = XCTestExpectation()

        // When
        sut.headIndexList(kid: [0xab, 0xcd], hashType: .uci)
            .done { _ in expectation.fulfill() }
            .cauterize()

        // Then
        wait(for: [expectation], timeout: 2)
        XCTAssertEqual(client.receivedHTTPRequest?.url, expectedURL)
        XCTAssertEqual(client.receivedHTTPRequest?.httpMethod?.uppercased(), "HEAD")
    }

    func testGetChunkListKIDHashType_error() {
        // Given
        client.error = NSError(domain: "TEST", code: 0)
        let expectation = XCTestExpectation()

        // When
        sut.getChunkList(kid: [0], hashType: .signature).catch { _ in expectation.fulfill() }

        // Then
        wait(for: [expectation], timeout: 2)
    }

    func testGetChunkListKIDHashType_response_not_cose() {
        // Given
        client.response = .mock(data: Data([1,2,3]))
        let expectation = XCTestExpectation()

        // When
        sut.getChunkList(kid: [0], hashType: .uci).catch { _ in expectation.fulfill() }

        // Then
        wait(for: [expectation], timeout: 2)
    }

    func testGetChunkListKIDHashType_success() throws {
        // Given
        let expectedURL = baseURL.appendingPathComponent("/abcd0a/chunk.lst")
        let expectation = XCTestExpectation()
        try prepareHTTPClientForChunkListRequest()

        // When
        sut.getChunkList(kid: [0xab, 0xcd], hashType: .signature)
            .done { response in
                XCTAssertEqual(response.lastModified, "ABC")
                expectation.fulfill()
            }
            .cauterize()

        // Then
        wait(for: [expectation], timeout: 2)
        XCTAssertEqual(client.receivedHTTPRequest?.url, expectedURL)
        XCTAssertEqual(client.receivedHTTPRequest?.httpMethod?.uppercased(), "GET")
    }

    private func prepareHTTPClientForChunkListRequest() throws {
        let base64EncodedResponse = "0oRDoQEmoFhFhFC0Zff0hOdW4PZW8UegdDAKUO9Hb1J+mFwgTn4XDriS83VQprigG2cDDzLg49cFKnGmiFDs4TCh/QAcf8YZ8aAZWzGsWEBzfym6BRubH/lzn4MpVo1M7K/d5+fY+Vt+670fTfHxdbXnRMojTWe45T2TKElsrWyciUVFPlHbTkTtdmS072Vu"
        let data = try XCTUnwrap(Data(base64Encoded: base64EncodedResponse))
        let response = try XCTUnwrap(
            HTTPURLResponse(
                url: baseURL,
                statusCode: 200,
                httpVersion: nil,
                headerFields: [
                    "Last-Modified": "ABC"
                ]
            )
        )
        client.response = .mock(httpURLResponse: response, data: data)
    }

    func testHeadChunkListKIDHashType_error() {
        // Given
        client.error = NSError(domain: "TEST", code: 0)
        let expectation = XCTestExpectation()

        // When
        sut.headChunkList(kid: [0], hashType: .signature).catch { _ in expectation.fulfill() }

        // Then
        wait(for: [expectation], timeout: 2)
    }

    func testHeadChunkListKIDHashType_success() throws {
        // Given
        let expectedURL = baseURL.appendingPathComponent("/abcd0b/chunk.lst")
        let expectation = XCTestExpectation()
        try prepareHTTPClientForChunkListRequest()

        // When
        sut.headChunkList(kid: [0xab, 0xcd], hashType: .uci)
            .done { _ in expectation.fulfill() }
            .cauterize()

        // Then
        wait(for: [expectation], timeout: 2)
        XCTAssertEqual(client.receivedHTTPRequest?.url, expectedURL)
        XCTAssertEqual(client.receivedHTTPRequest?.httpMethod?.uppercased(), "HEAD")
    }

    func testGetChunkListKIDHashTypeBytes_error() {
        // Given
        client.error = NSError(domain: "TEST", code: 0)
        let expectation = XCTestExpectation()

        // When
        sut.getChunkList(kid: [0], hashType: .signature, byte1: 0xAF, byte2: 0xA0)
            .catch { _ in expectation.fulfill() }

        // Then
        wait(for: [expectation], timeout: 2)
    }

    func testGetChunkListKIDHashTypeBytes_response_not_cose() {
        // Given
        client.response = .mock(data: Data([1,2,3]))
        let expectation = XCTestExpectation()

        // When
        sut.getChunkList(kid: [0], hashType: .uci, byte1: 0xAF, byte2: 0xA0)
            .catch { _ in expectation.fulfill() }

        // Then
        wait(for: [expectation], timeout: 2)
    }

    func testGetChunkListKIDHashTypeBytes_success() throws {
        // Given
        let expectedURL = baseURL.appendingPathComponent("/abcd0a/af/a0/chunk.lst")
        let expectation = XCTestExpectation()
        try prepareHTTPClientForChunkListRequest()

        // When
        sut.getChunkList(kid: [0xAB, 0xCD], hashType: .signature, byte1: 0xAF, byte2: 0xA0)
            .done { _ in expectation.fulfill() }
            .cauterize()

        // Then
        wait(for: [expectation], timeout: 2)
        XCTAssertEqual(client.receivedHTTPRequest?.url, expectedURL)
        XCTAssertEqual(client.receivedHTTPRequest?.httpMethod?.uppercased(), "GET")
    }

    func testGetChunkListKIDHashTypeByte1_success() throws {
        // Given
        let expectedURL = baseURL.appendingPathComponent("/abcd0a/af/chunk.lst")
        let expectation = XCTestExpectation()
        try prepareHTTPClientForChunkListRequest()

        // When
        sut.getChunkList(kid: [0xab, 0xcd], hashType: .signature, byte1: 0xAF, byte2: nil)
            .done { _ in expectation.fulfill() }
            .cauterize()

        // Then
        wait(for: [expectation], timeout: 2)
        XCTAssertEqual(client.receivedHTTPRequest?.url, expectedURL)
        XCTAssertEqual(client.receivedHTTPRequest?.httpMethod?.uppercased(), "GET")
    }

    func testGetChunkListKIDHashType_response_is_nil() throws {
        // Given
        client.response = .init(
            httpURLResponse: try XCTUnwrap(
                .init(
                    url: FileManager.default.temporaryDirectory,
                    statusCode: HTTPStatusCode.notModified,
                    httpVersion: nil,
                    headerFields: nil
                )
            ),
            data: nil
        )
        let expectation = XCTestExpectation()

        // When
        sut.getChunkList(kid: [1, 2, 3], hashType: .signature)
            .done { _ in }
            .catch { _ in
                expectation.fulfill()
            }

        // Then
        wait(for: [expectation], timeout: 2)
    }

    func testGetChunkListListHttpHeaders_response_data_is_nil() throws {
        // Given
        client.response = .mock(data: nil)
        let expectation = XCTestExpectation()

        // When
        sut.getChunkList(kid: [1, 2, 3], hashType: .uci, httpHeaders: [:])
            .done { _ in }
            .catch { _ in
                expectation.fulfill()
            }

        // Then
        wait(for: [expectation], timeout: 2)
    }

    func testGetChunkListKIDHashTypeBytes_response_data_is_nil() throws {
        // Given
        client.response = .mock(data: nil)
        let expectation = XCTestExpectation()

        // When
        sut.getChunkList(kid: [1, 2, 3], hashType: .uci, byte1: 1, byte2: nil)
            .done { _ in }
            .catch { _ in
                expectation.fulfill()
            }

        // Then
        wait(for: [expectation], timeout: 2)
    }

    func testHeadChunkListKIDHashTypeBytes_error() {
        // Given
        client.error = NSError(domain: "TEST", code: 0)
        let expectation = XCTestExpectation()

        // When
        sut.headChunkList(kid: [0], hashType: .signature, byte1: 0xAF, byte2: 0xA0)
            .catch { _ in expectation.fulfill() }

        // Then
        wait(for: [expectation], timeout: 2)
    }

    func testHeadChunkListKIDHashTypeBytes_success() throws {
        // Given
        let expectedURL = baseURL.appendingPathComponent("/abcd0b/af/a0/chunk.lst")
        let expectation = XCTestExpectation()
        try prepareHTTPClientForChunkListRequest()

        // When
        sut.headChunkList(kid: [0xab, 0xcd], hashType: .uci, byte1: 0xAF, byte2: 0xA0)
            .done { _ in expectation.fulfill() }
            .cauterize()

        // Then
        wait(for: [expectation], timeout: 2)
        XCTAssertEqual(client.receivedHTTPRequest?.url, expectedURL)
        XCTAssertEqual(client.receivedHTTPRequest?.httpMethod?.uppercased(), "HEAD")
    }

    func testHeadChunkListKIDHashTypeByte1_success() throws {
        // Given
        let expectedURL = baseURL.appendingPathComponent("/abcd0b/af/chunk.lst")
        let expectation = XCTestExpectation()
        try prepareHTTPClientForChunkListRequest()

        // When
        sut.headChunkList(kid: [0xab, 0xcd], hashType: .uci, byte1: 0xAF, byte2: nil)
            .done { _ in expectation.fulfill() }
            .cauterize()

        // Then
        wait(for: [expectation], timeout: 2)
        XCTAssertEqual(client.receivedHTTPRequest?.url, expectedURL)
        XCTAssertEqual(client.receivedHTTPRequest?.httpMethod?.uppercased(), "HEAD")
    }

    func testGetKIDList_response_does_not_verify() throws {
        // Given
        let expectedURL = baseURL.appendingPathComponent("/kid.lst")
        let expectation = XCTestExpectation()
        let base64EncodedCoseMessage = "0oRDoQEmoQRQjt4zFtTaQYGB8HU6/8ajo1kBHKQBYkRFBBpidoyjBhpglVkjOQEDoQGkYXaBqmJjaXgxMDFERS8wMDEwMC8xMTE5MzQ5MDA3L0Y0RzcwMTRLUVEyWEQwTlk4RkpIU1REWFojU2Jjb2JERWJkbgJiZHRqMjAyMS0wMi0yOGJpc3gqQnVuZGVzbWluaXN0ZXJpdW0gZsO8ciBHZXN1bmRoZWl0IChUZXN0MDEpYm1hbU9SRy0xMDAwMzAyMTVibXBsRVUvMS8yMC8xNTI4YnNkAmJ0Z2k4NDA1MzkwMDZidnBqMTExOTM0OTAwN2Nkb2JqMTk5Ny0wMS0wNmNuYW2kYmZuZUlvbnV0YmduZUJhbGFpY2ZudGVJT05VVGNnbnRlQkFMQUljdmVyZTEuMC4wWEC9eoLxc6ULO8vhrnBQOPL+/aSF3+8xgoDLe1eO3+KcfWFuHEw/nDp8bSJju6yAjah5f3TRH5fq6kyR+9ts/3yY"
        let data = try XCTUnwrap(Data(base64Encoded: base64EncodedCoseMessage))
        client.response = .mock(data: data)

        // When
        sut.getKIDList().catch { _ in expectation.fulfill() }

        // Then
        wait(for: [expectation], timeout: 2)
        XCTAssertEqual(client.receivedHTTPRequest?.url, expectedURL)
        XCTAssertEqual(client.receivedHTTPRequest?.httpMethod?.uppercased(), "GET")
    }
    
    func testGetKIDListHttpHeaders_not_modified() throws {
        // Given
        let httpURLResponse = try XCTUnwrap(
            HTTPURLResponse(
                url: FileManager.default.temporaryDirectory,
                statusCode: HTTPStatusCode.notModified,
                httpVersion: nil,
                headerFields: nil
            )
        )
        let expectation = XCTestExpectation()
        client.response = .mock(httpURLResponse: httpURLResponse, data: nil)

        // When
        sut.getKIDList(httpHeaders: ["my-header": "value"])
            .done { response in
                let value = self.client.receivedHTTPRequest?.value(
                    forHTTPHeaderField: "my-header"
                )
                XCTAssertEqual(value, "value")
                XCTAssertNil(response)
                expectation.fulfill()
            }
            .cauterize()

        // Then
        wait(for: [expectation], timeout: 2)
    }

    func testGetIndexListHttpHeaders_not_modified() throws {
        // Given
        let httpURLResponse = try XCTUnwrap(
            HTTPURLResponse(
                url: FileManager.default.temporaryDirectory,
                statusCode: HTTPStatusCode.notModified,
                httpVersion: nil,
                headerFields: nil
            )
        )
        let expectation = XCTestExpectation()
        client.response = .mock(httpURLResponse: httpURLResponse, data: nil)

        // When
        sut.getIndexList(
            kid: [0x1, 0x2, 0x3],
            hashType: .signature,
            httpHeaders: ["my-header": "value"]
        )
        .done { response in
            let value = self.client.receivedHTTPRequest?.value(
                forHTTPHeaderField: "my-header"
            )
            XCTAssertEqual(value, "value")
            XCTAssertNil(response)
            expectation.fulfill()
        }
        .cauterize()

        // Then
        wait(for: [expectation], timeout: 2)
    }

    func testGetChunkListHttpHeaders_not_modified() throws {
        // Given
        let httpURLResponse = try XCTUnwrap(
            HTTPURLResponse(
                url: FileManager.default.temporaryDirectory,
                statusCode: HTTPStatusCode.notModified,
                httpVersion: nil,
                headerFields: nil
            )
        )
        let expectation = XCTestExpectation()
        client.response = .mock(httpURLResponse: httpURLResponse, data: nil)

        // When
        sut.getChunkList(
            kid: [0x1, 0x2, 0x3],
            hashType: .signature,
            httpHeaders: ["my-header": "value"]
        )
        .done { response in
            let value = self.client.receivedHTTPRequest?.value(
                forHTTPHeaderField: "my-header"
            )
            XCTAssertEqual(value, "value")
            XCTAssertNil(response)
            expectation.fulfill()
        }
        .cauterize()

        // Then
        wait(for: [expectation], timeout: 2)
    }
}

private let publicKey = """
-----BEGIN PUBLIC KEY-----
MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAE6Ft4aTjScTpsvY0tg2Lx0AK0Ih3Z
2VKXnyBvoZxngB9cXmNtTg+Va3fY3QJduf+OXaWsE34xvMTIHxw+MpOLkw==
-----END PUBLIC KEY-----
"""
