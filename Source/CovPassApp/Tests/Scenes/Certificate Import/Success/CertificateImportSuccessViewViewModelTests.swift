//
//  CertificateImportSuccessViewViewModelTests.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassApp
import PromiseKit
import XCTest

class CertificateImportSuccessViewViewModelTests: XCTestCase {
    private var sut: CertificateImportSuccessViewViewModel!

    override func setUpWithError() throws {
        let (_, resolver) = Promise<Void>.pending()
        sut = .init(resolver: resolver)
    }

    override func tearDownWithError() throws {
        sut = nil
    }

    func testTitle() {
        // When
        let title = sut.title

        // Then
        XCTAssertEqual(title, "Import successful")
    }

    func testDescription() {
        // When
        let description = sut.description

        // Then
        XCTAssertEqual(description, "You can now continue to use your certificate(s) as usual.")
    }

    func testButtonTitle() {
        // When
        let buttonTitle = sut.buttonTitle

        // Then
        XCTAssertEqual(buttonTitle, "OK")
    }
}
