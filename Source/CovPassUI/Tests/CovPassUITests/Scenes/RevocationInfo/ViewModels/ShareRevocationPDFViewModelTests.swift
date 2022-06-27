//
//  ShareRevocationPDFViewModelTests.swift
//  
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassUI
import PDFKit
import XCTest

class ShareRevocationPDFViewModelTests: XCTestCase {
    private var sut: ShareRevocationPDFViewModel!
    private var url: URL!
    override func setUpWithError() throws {
        let fileManager = FileManager.default
        url = fileManager.temporaryDirectory
            .appendingPathComponent("1234_Germany_2001-01-01.pdf")
        try? fileManager.removeItem(at: url)
        sut = .init(
            exportData: RevocationPDFExportData(
                pdfDocument: PDFDocument(),
                issuingCountry: "Germany",
                transactionNumber: "1234",
                date: Date(timeIntervalSinceReferenceDate: 0),
                fileManager: fileManager
            )
        )
    }

    override func tearDownWithError() throws {
        try? FileManager.default.removeItem(at: url)
        sut = nil
        url = nil
    }

    func testInit() {
        // Then
        XCTAssertTrue(FileManager.default.fileExists(atPath: url.path))
    }

    func testHandleActivityResult() {
        // When
        sut.handleActivityResult(completed: false, activityError: nil)

        // Then
        XCTAssertFalse(FileManager.default.fileExists(atPath: url.path))
    }
}
