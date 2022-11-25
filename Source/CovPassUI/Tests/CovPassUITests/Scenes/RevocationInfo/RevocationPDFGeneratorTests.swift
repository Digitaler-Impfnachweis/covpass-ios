//
//  RevocationPDFGeneratorTests.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
@testable import CovPassUI
import Foundation
import PDFKit
import XCTest

class RevocationPDFGeneratorTests: XCTestCase {
    private var converter: SVGToPDFConverterMock!
    private var sut: RevocationPDFGenerator!
    override func setUpWithError() throws {
        converter = SVGToPDFConverterMock()
        let url = try XCTUnwrap(Bundle.module.url(forResource: "RevocationInfoTemplate", withExtension: "svg"))
        let data = try XCTUnwrap(Data(contentsOf: url))
        let template = try XCTUnwrap(String(data: data, encoding: .utf8))
        sut = .init(
            converter: converter,
            jsonEncoder: JSONEncoder(),
            svgTemplate: template,
            secKey: try SecKey.mock()
        )
    }

    override func tearDownWithError() throws {
        converter = nil
        sut = nil
    }

    func testGenerate_success() {
        // Given
        let expectation = XCTestExpectation()

        // When
        sut.generate(with: .mock())
            .done { _ in
                expectation.fulfill()
            }
            .catch { _ in
                XCTFail("Must not fail.")
            }

        // Then
        wait(for: [expectation], timeout: 2)
    }

    func testGenerate_invalid_template() throws {
        // Given
        let expectation = XCTestExpectation()
        sut = .init(
            converter: converter,
            jsonEncoder: JSONEncoder(),
            svgTemplate: "",
            secKey: try SecKey.mock()
        )

        // When
        sut.generate(with: .mock())
            .done { _ in
                XCTFail("Must not succeed.")
            }
            .catch { _ in
                expectation.fulfill()
            }

        // Then
        wait(for: [expectation], timeout: 2)
    }
}

private extension RevocationInfo {
    static func mock() -> Self {
        .init(
            transactionNumber: "",
            kid: "", rValueSignature: "",
            issuingCountry: "",
            technicalExpiryDate: "",
            dateOfIssue: ""
        )
    }
}

private extension SecKey {
    static func mock() throws -> SecKey {
        let keyPEM = """
        -----BEGIN PUBLIC KEY-----
        MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEIxHvrv8jQx9OEzTZbsx1prQVQn/3
        ex0gMYf6GyaNBW0QKLMjrSDeN6HwSPM0QzhvhmyQUixl6l88A7Zpu5OWSw==
        -----END PUBLIC KEY-----
        """
        let key = try keyPEM.secKey()
        return key
    }
}
