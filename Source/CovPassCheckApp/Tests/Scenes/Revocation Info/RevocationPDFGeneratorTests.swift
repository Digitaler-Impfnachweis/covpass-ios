//
//  RevocationPDFGeneratorTests.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassCheckApp
import Foundation
import XCTest
import CovPassCommon
import PDFKit

class RevocationPDFGeneratorTests: XCTestCase {
    private var converter: SVGToPDFConverterMock!
    private var sut: RevocationPDFGenerator!
    override func setUpWithError() throws {
        converter = SVGToPDFConverterMock()
        let url = try XCTUnwrap(Bundle.main.url(forResource: "RevocationInfoTemplate", withExtension: "svg"))
        let data = try XCTUnwrap(Data(contentsOf: url))
        let template = try XCTUnwrap(String(data: data, encoding: .utf8))
        sut = .init(converter: converter, svgTemplate: template)
    }

    override func tearDownWithError() throws {
        converter = nil
        sut = nil
    }

    func testGenerate_success() {
        // Given
        let expectation = XCTestExpectation()

        // When
        sut.generate(with: .init(expirationDate: "", issuingCountry: "", qrCode: "", revocationCode: ""))
            .done { pdfDocument in
                expectation.fulfill()
            }
            .catch { _ in
                XCTFail("Must not fail.")
            }

        // Then
        wait(for: [expectation], timeout: 2)
    }

    func testGenerate_invalid_template() {
        // Given
        let expectation = XCTestExpectation()
        sut = .init(converter: converter, svgTemplate: "")

        // When
        sut.generate(with: .init(expirationDate: "", issuingCountry: "", qrCode: "", revocationCode: ""))
            .done { pdfDocument in
                XCTFail("Must not succeed.")
            }
            .catch { _ in
                expectation.fulfill()
            }

        // Then
        wait(for: [expectation], timeout: 2)
    }

}
