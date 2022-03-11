//
//  RevocationPDFExportDataTests.swift
//  
//
//  Created by Thomas Kuleßa on 10.03.22.
//

@testable import CovPassUI
import PDFKit
import XCTest

class RevocationPDFExportDataTests: XCTestCase {
    private var fileManager: FileManagerMock!
    private var sut: RevocationPDFExportData!

    override func setUpWithError() throws {
        fileManager = .init()
        sut = .init(
            pdfDocument: PDFDocument(),
            issuingCountry: "Germany",
            transactionNumber: "1234",
            date: .init(timeIntervalSinceReferenceDate: 0),
            fileManager: fileManager
        )
    }

    override func tearDownWithError() throws {
        fileManager = nil
        sut = nil
    }

    func testFileURL() {
        // Given
        let expectedURL = fileManager.temporaryDirectory
            .appendingPathComponent("1234_Germany_01.01.2001.pdf")

        // When
        let url = sut.fileURL

        // Then
        XCTAssertEqual(url, expectedURL)
    }

    func testWrite() {
        // Given
        let path = FileManager.default.temporaryDirectory
            .appendingPathComponent("1234_Germany_01.01.2001.pdf")
            .path

        // When
        sut.write()

        // Then
        let fileExists = FileManager.default.fileExists(atPath: path)
        XCTAssertTrue(fileExists)
    }

    func testDelete_success() throws {
        // Given
        let url = fileManager.temporaryDirectory
            .appendingPathComponent("1234_Germany_01.01.2001.pdf")
        sut.write()

        // When
        try sut.delete()

        // Then
        wait(for: [fileManager.removeItemExpectation], timeout: 1)
        XCTAssertEqual(fileManager.removeItemURL, url)
    }

    func testDelete_failure() {
        // Given
        fileManager.error = NSError(domain: "TEST", code: 0, userInfo: nil)

        // When & Then
        XCTAssertThrowsError(try sut.delete())
    }
}
