//
//  PublicKeyPinningTests.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassCommon
import XCTest

class HTTPClientCertificatePinningTests: XCTestCase {
    /// Testing ~~certificate~~ public key pinning mechanism on a valid and invalid host.
    func testPinning() throws {
        let urlSessionDelegate = APIServiceDelegate(
            publicKeyHashes: ["35bc5ff1a9e64dde09042804e1502140c6cbbe24fba4d5d0b9417f007849aed5"]
        )
        let session = URLSession(configuration: URLSessionConfiguration.ephemeral, delegate: urlSessionDelegate, delegateQueue: nil)

        let validURL = try XCTUnwrap(URL(string: "https://distribution.dcc-rules.de/rules"))
        let invalidURL = try XCTUnwrap(URL(string: "https://example.com"))

        let taskFinished = expectation(description: "data task finished")
        taskFinished.expectedFulfillmentCount = 2 // 1x valid, 1x invalid

        let task1 = session.dataTask(with: validURL) { _, response, error in

            try? XCTSkipIf(response == nil, "Pinning could not be determined because our server is not responding.")

            guard let response = response as? HTTPURLResponse else {
                taskFinished.fulfill()
                return
            }
            XCTAssertEqual(response.statusCode, 200)
            XCTAssertNil(error)
            taskFinished.fulfill()
        }
        task1.resume()

        let task2 = session.dataTask(with: invalidURL) { data, response, error in
            // no data, no response (because no request)
            XCTAssertNil(data)
            XCTAssertNil(response)

            // failed pinning results in a 'cancelled' error
            let error = error as NSError?
            XCTAssertEqual(error?.domain, NSURLErrorDomain)
            XCTAssertEqual(error?.code, NSURLErrorCancelled)
            taskFinished.fulfill()
        }
        task2.resume()

        waitForExpectations(timeout: 30)
    }
}
