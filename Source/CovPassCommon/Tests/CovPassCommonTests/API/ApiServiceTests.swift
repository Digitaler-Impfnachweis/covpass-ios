//
//  ApiServiceTests.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import XCTest
import PromiseKit

@testable import CovPassCommon

class CustomURLSessionMock: CustomURLSessionProtocol {
    var requestResponse: Promise<String>?
    func request(_ urlRequest: URLRequest) -> Promise<String> {
        requestResponse ?? Promise(error: ApplicationError.unknownError)
    }
}

class ApiServiceTests: XCTestCase {
    var sut: APIService!
    var sessionMock: CustomURLSessionMock!

    override func setUp() {
        super.setUp()
        sessionMock = CustomURLSessionMock()
        sut = APIService(customURLSession: sessionMock, url: "https://digitaler-impfnachweis-app.de")
    }

    override func tearDown() {
        sut = nil
        sessionMock = nil
        super.tearDown()
    }

    func testFetchTrustList() throws {
        sessionMock.requestResponse = Promise.value("foo")
        let res = try sut.fetchTrustList().wait()
        XCTAssertEqual(res, "foo")
    }

    func testFetchTrustListFails() throws {
        sessionMock.requestResponse = Promise(error: APIError.invalidResponse)
        do {
            _ = try sut.fetchTrustList().wait()
            XCTFail("Should fail")
        } catch {
            XCTAssertEqual(error.localizedDescription, APIError.invalidResponse.localizedDescription)
        }
    }
}
