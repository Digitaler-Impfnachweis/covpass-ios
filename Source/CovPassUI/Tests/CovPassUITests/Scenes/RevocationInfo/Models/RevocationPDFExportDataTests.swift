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
    private var fileURL: URL!
    private var sut: RevocationPDFExportData!

    override func setUpWithError() throws {
        fileManager = .init()
        sut = .init(
            pdfDocument: PDFDocument(),
            issuingCountry: "DE",
            transactionNumber: "1234",
            date: .init(timeIntervalSinceReferenceDate: 0),
            fileManager: fileManager
        )
        fileURL = fileManager.temporaryDirectory
            .appendingPathComponent("1234_DE_2001-01-01.pdf")
    }

    override func tearDownWithError() throws {
        fileManager = nil
        fileURL = nil
        sut = nil
    }

    func testFileURL() {
        // When
        let url = sut.fileURL

        // Then
        XCTAssertEqual(url, fileURL)
    }

    func testWrite() {
        // Given
        let path = fileURL.path

        // When
        sut.write()

        // Then
        let fileExists = FileManager.default.fileExists(atPath: path)
        XCTAssertTrue(fileExists)
    }

    func testDelete_success() throws {
        // Given
        sut.write()

        // When
        try sut.delete()

        // Then
        wait(for: [fileManager.removeItemExpectation], timeout: 1)
        XCTAssertEqual(fileManager.removeItemURL, fileURL)
    }

    func testDelete_failure() {
        // Given
        fileManager.error = NSError(domain: "TEST", code: 0, userInfo: nil)

        // When & Then
        XCTAssertThrowsError(try sut.delete())
    }
}
