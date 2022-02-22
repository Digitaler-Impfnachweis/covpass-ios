//
//  URLSession+CertificateReissueTests.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassApp
import CovPassCommon
import Foundation
import XCTest

class URLSession_CertificateReissueTests: XCTestCase {
    func testCertificateReissue() throws {
        // Given
        let mimeType = "application/json"

        // When
        let sut = URLSession.certificateReissue()

        // Then
        let configuration = sut.configuration
        let headers = try XCTUnwrap(configuration.httpAdditionalHeaders)
        let contentType = headers["Content-Type"] as? String
        let accept = headers["Accept"] as? String
        XCTAssertTrue(sut.delegate is APIServiceDelegate)
        XCTAssertEqual(configuration.requestCachePolicy, .useProtocolCachePolicy)
        XCTAssertEqual(contentType, mimeType)
        XCTAssertEqual(accept, mimeType)
    }
}
