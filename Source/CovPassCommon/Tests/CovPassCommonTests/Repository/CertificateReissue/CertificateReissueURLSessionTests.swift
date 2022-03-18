//
//  CertificateReissueURLSessionTests.swift
//  
//
//  Created by Thomas Kuleßa on 21.02.22.
//

@testable import CovPassCommon
import Foundation
import PromiseKit
import XCTest

class CertificateReissueURLSessionTests: XCTestCase {
    var sut: CertificateReissueURLSession!

    override func setUpWithError() throws {
        sut = CertificateReissueURLSession(
            urlSession: .shared
        )
    }

    override func tearDownWithError() throws {
        sut = nil
    }

    func testHttpRequest_file_url() {
        // Given
        let url = FileManager.default.temporaryDirectory
        let request = URLRequest(url: url)
        let expectation = XCTestExpectation()

        // When
        sut.httpRequest(request)
            .done { data in
                expectation.fulfill()
            }
            .catch { error in
                expectation.fulfill()
            }
        
        // Then
        wait(for: [expectation], timeout: 2)
    }

    func testHttpRequest_localhost() throws {
        // Given
        let url = try XCTUnwrap(URL(string: "https://localhost"))
        let request = URLRequest(url: url)
        let expectation = XCTestExpectation()

        // When
        sut.httpRequest(request)
            .done { data in
                expectation.fulfill()
            }
            .catch { error in
                expectation.fulfill()
            }

        // Then
        wait(for: [expectation], timeout: 2)
    }
}
