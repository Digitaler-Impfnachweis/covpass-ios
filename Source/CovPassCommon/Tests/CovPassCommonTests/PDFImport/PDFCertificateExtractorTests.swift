//
//  PDFCertificateExtractorTests.swift
//  
//
//  Created by Thomas Kuleßa on 10.06.22.
//

@testable import CovPassCommon
import XCTest

class PDFCertificateExtractorTests: XCTestCase {
    private var sut: PDFCBORExtractor!
    private var coseSign1MessageConverter: CoseSign1MessageConverterMock!
    private var document: QRCodePDFDocumentMock!
    private var revocationRepository: CertificateRevocationRepositoryMock!

    override func setUpWithError() throws {
        coseSign1MessageConverter = .init()
        document = .init()
        revocationRepository = .init()
        configureSut()
    }

    override func tearDownWithError() throws {
        sut = nil
        coseSign1MessageConverter = nil
        document = nil
        revocationRepository = nil
    }

    func configureSut(
        maximalNumberOfTokens: Int = 100,
        existingTokens: [ExtendedCBORWebToken] = []
    ) {
        sut = .init(
            document: document,
            maximalNumberOfTokens: maximalNumberOfTokens,
            existingTokens: existingTokens,
            coseSign1MessageConverter: coseSign1MessageConverter,
            revocationRepository: revocationRepository,
            queue: .init(label: "Test Queue")
        )
    }

    func testExtract_valid_token() {
        // Given
        let expectation = XCTestExpectation()
        document.qrCodes = [
            .init(["QR CODE DATA"])
        ]
        configureSut()

        // When
        sut.extract()
            .done { tokens in
                // Then
                XCTAssertEqual(tokens.count, 1)
                expectation.fulfill()
            }
            .catch { _ in
                XCTFail("Must not fail.")
            }

        wait(for: [
            expectation,
            revocationRepository.isRevokedExpectation,
            coseSign1MessageConverter.convertExpectation
        ], timeout: 1)
    }

    func testExtract_token_revoked() {
        // Given
        let expectation = XCTestExpectation()
        document.qrCodes = [
            .init(["QR CODE DATA"])
        ]
        revocationRepository.isRevoked = true
        configureSut()

        // When
        sut.extract()
            .done { tokens in
                XCTAssertEqual(tokens.count, 0)
                expectation.fulfill()
            }
            .catch { _ in
                XCTFail("Must not fail.")
            }

        wait(for: [expectation], timeout: 1)
    }

    func testExtract_document_has_error() {
        // Given
        let expectation = XCTestExpectation()
        document.qrCodes = [
            .init(["QR CODE DATA"])
        ]
        document.error = NSError(domain: "TEST", code: 0)
        configureSut()

        // When
        sut.extract()
            .done { _ in
                XCTFail("Must not succeed.")
            }
            .catch { _ in
                expectation.fulfill()
            }

        wait(for: [expectation], timeout: 1)
    }

    func testExtract_token_verification_fails() {
        // Given
        let expectation = XCTestExpectation()
        document.qrCodes = [
            .init(["QR CODE DATA"])
        ]
        coseSign1MessageConverter.error = NSError(domain: "TEST", code: 0)
        configureSut()

        // When
        sut.extract()
            .done { tokens in
                XCTAssertEqual(tokens.count, 0)
                expectation.fulfill()
            }
            .catch { _ in
                XCTFail("Must not fail.")
            }

        wait(for: [expectation], timeout: 1)
    }

    func testExtract_token_already_exists() {
        // Given
        let expectation = XCTestExpectation()
        let token = CBORWebToken.mockVaccinationCertificate.extended(vaccinationQRCodeData: "QR CODE DATA")
        document.qrCodes = [
            .init(["QR CODE DATA"])
        ]
        configureSut(existingTokens: [token])

        // When
        sut.extract()
            .done { tokens in
                // Then
                XCTAssertEqual(tokens.count, 0)
                expectation.fulfill()
            }
            .catch { _ in
                XCTFail("Must not fail.")
            }

        wait(for: [expectation], timeout: 1)
    }

    func testExtract_valid_tokens_exceed_maximum() {
        // Given
        let expectation = XCTestExpectation()
        document.qrCodes = [
            .init(["1", "2", "3"]),
            .init(["4"]),
            .init(["5", "6"])
        ]
        configureSut(maximalNumberOfTokens: 4)

        // When
        sut.extract()
            .done { tokens in
                // Then
                XCTAssertEqual(tokens.count, 4)
                let qrCodes = tokens.map(\.vaccinationQRCodeData)
                XCTAssertTrue(qrCodes.contains("1"))
                XCTAssertTrue(qrCodes.contains("2"))
                XCTAssertTrue(qrCodes.contains("3"))
                XCTAssertTrue(qrCodes.contains("4"))
                expectation.fulfill()
            }
            .catch { _ in
                XCTFail("Must not fail.")
            }

        wait(for: [expectation], timeout: 1)
    }

    func testExtract_duplicate_tokens() {
        // Given
        let expectation = XCTestExpectation()
        document.qrCodes = [
            .init(["1", "2", "3"]),
            .init(["1", "2", "3"]),
            .init(["1", "2", "3"]),
            .init(["1", "2", "3"]),
            .init(["1", "2", "3"])
        ]
        configureSut()

        // When
        sut.extract()
            .done { tokens in
                // Then
                XCTAssertEqual(tokens.count, 3)
                let qrCodes = tokens.map(\.vaccinationQRCodeData)
                XCTAssertTrue(qrCodes.contains("1"))
                XCTAssertTrue(qrCodes.contains("2"))
                XCTAssertTrue(qrCodes.contains("3"))
                expectation.fulfill()
            }
            .catch { _ in
                XCTFail("Must not fail.")
            }

        wait(for: [
            expectation
        ], timeout: 1)
    }
}
