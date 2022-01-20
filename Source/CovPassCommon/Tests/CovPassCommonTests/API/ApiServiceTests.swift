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
    var sessionMock2: CustomURLSession!

    override func setUp() {
        super.setUp()
        sessionMock = CustomURLSessionMock()
        sessionMock2 = CustomURLSession(sessionDelegate: nil)
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
    
    func testUserAgent() throws {
        XCTAssertNotNil(CustomURLSession.defaultHTTPHeaders)
        let headers = CustomURLSession.defaultHTTPHeaders
        let keys = headers.keys
        XCTAssert(keys.contains("Accept-Language"))
        XCTAssert(keys.contains("Accept-Encoding"))
        XCTAssert(keys.contains("User-Agent"))
        let valueUserAgent = headers["User-Agent"]!
        let valueEncoding = headers["Accept-Encoding"]!
        let valueLanguage = headers["Accept-Language"]!
        XCTAssert(valueUserAgent.contains("iOS"))
        XCTAssert(valueUserAgent.contains("build"))
        XCTAssert(valueUserAgent.contains("xctest"))
        XCTAssert(valueEncoding == "gzip;q=1.0, compress;q=0.5")
        XCTAssert(valueLanguage.contains("en"))
        XCTAssert(valueLanguage.contains("q=1.0"))
    }
    
    func testUpdateEtagNil() throws {
        let urlString = "http://test.test"
        let url = URL(string: urlString)!
        let urlResponse = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
        UserDefaults.standard.setValue(nil, forKey: urlString)
        CustomURLSession.updateETag(urlResponse: urlResponse)
        let etag = APIService.eTagForURL(urlString: urlString)
        XCTAssertNil(etag)
    }
    
    func testUpdateEtagSucessfull() throws {
        let url = URL(string: "http://test.test")!
        let eTagValue = "etagExample"
        let urlResponse = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: [CustomURLSession.apiHeaderETag : eTagValue])
        let urlString = urlResponse!.url!.absoluteString
        CustomURLSession.updateETag(urlResponse: urlResponse)
        let etag = APIService.eTagForURL(urlString: urlString)
        XCTAssertEqual(etag, eTagValue)
    }
    
    func testUpdateEtagSucessfullMultiple() throws {
        
        let urls = ["http://test1.test", "http://test2.test", "http://test3.test"]
        let eTags = ["etagExample1", "etagExample2", "etagExample3"]
        
        for i in 0...urls.count-1 {
            let eTag = eTags[i]
            let url = URL(string: urls[i])!
            let urlResponse = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: [CustomURLSession.apiHeaderETag : eTag])
            CustomURLSession.updateETag(urlResponse: urlResponse)
        }
        
        for i in 0...urls.count-1 {
            let eTag = eTags[i]
            let url = URL(string: urls[i])!
            let eTagPersistet = APIService.eTagForURL(urlString: url.absoluteString)
            XCTAssertEqual(eTagPersistet, eTag)
        }
    }
}
