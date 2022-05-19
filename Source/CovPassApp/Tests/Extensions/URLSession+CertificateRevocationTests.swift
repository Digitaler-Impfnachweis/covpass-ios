//
//  URLSession+CertificateRevocationTests.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassApp
import CovPassCommon
import Foundation
import XCTest

class URLSession_CertificateRevocationTests: XCTestCase {
    func testCertificateRevocation() throws {
        // When
        let sut = URLSession.certificateRevocation()

        // Then
        let configuration = sut.configuration
        XCTAssertTrue(sut.delegate is APIServiceDelegate)
        XCTAssertEqual(configuration.requestCachePolicy, .useProtocolCachePolicy)
    }
}

