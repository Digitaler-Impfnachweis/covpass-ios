//
//  HTTPClientTests.swift
//  
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassCommon
import Foundation
import PromiseKit
import XCTest

class HTTPClientTests: XCTestCase {
    private var dataTaskProducer: DataTaskProducerMock!
    private var request: URLRequest!
    private var sut: HTTPClient!

    override func setUpWithError() throws {
        dataTaskProducer = DataTaskProducerMock()
        sut = HTTPClient(
            dataTaskProducer: dataTaskProducer
        )
        let url = try XCTUnwrap(URL(string: "https://localhost"))
        request = URLRequest(url: url)
    }

    override func tearDownWithError() throws {
        dataTaskProducer = nil
        request = nil
        sut = nil
    }

    func testHttpRequest_success() throws {
        // Given
        let expectation = XCTestExpectation()

        // When
        sut.httpRequest(request)
            .done { _ in
                expectation.fulfill()
            }
            .cauterize()

        // Then
        wait(for: [expectation], timeout: 2)
    }

    func testHttpRequest_no_data() throws {
        // Given
        dataTaskProducer.data = nil
        let expectation = XCTestExpectation()

        // When
        sut.httpRequest(request)
            .done { response in
                XCTAssertNil(response.data)
                expectation.fulfill()
            }
            .cauterize()
        
        // Then
        wait(for: [expectation], timeout: 2)
    }

    func testHttpRequest_http_error() throws {
        // Given
        dataTaskProducer.response = try XCTUnwrap(
            HTTPURLResponse(
                url: try XCTUnwrap(request.url),
                statusCode: 500,
                httpVersion: nil,
                headerFields: nil
            )
        )
        let expectation = XCTestExpectation()

        // When
        sut.httpRequest(request)
            .catch { error in
                guard let httpClientError = error as? HTTPClientError, case .http = httpClientError else {
                    XCTFail("Wrong error")
                    return
                }
                expectation.fulfill()
            }

        // Then
        wait(for: [expectation], timeout: 2)
    }

    func testHttpRequest_other_error() throws {
        // Given
        dataTaskProducer.error = NSError(domain: "", code: -1)
        let expectation = XCTestExpectation()

        // When
        sut.httpRequest(request)
            .catch { error in
                expectation.fulfill()
            }

        // Then
        wait(for: [expectation], timeout: 2)
    }

    func testHttpRequest_NSURLErrorCancelled() throws {
        // Given
        dataTaskProducer.error = NSError(domain: NSURLErrorDomain, code: NSURLErrorCancelled)
        let expectation = XCTestExpectation()

        // When
        sut.httpRequest(request)
            .catch { error in
                expectation.fulfill()
            }

        // Then
        wait(for: [expectation], timeout: 2)
    }

    func testHttpRequest_http_notModified() throws {
        // Given
        dataTaskProducer.response = try XCTUnwrap(
            HTTPURLResponse(
                url: try XCTUnwrap(request.url),
                statusCode: HTTPStatusCode.notModified,
                httpVersion: nil,
                headerFields: nil
            )
        )
        let expectation = XCTestExpectation()

        // When
        sut.httpRequest(request)
            .done { response in
                expectation.fulfill()
            }
            .cauterize()

        // Then
        wait(for: [expectation], timeout: 2)
    }
}
