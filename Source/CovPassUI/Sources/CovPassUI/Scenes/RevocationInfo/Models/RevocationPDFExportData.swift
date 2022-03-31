//
//  RevocationPDFExportData.swift
//  
//
//  Created by Thomas Kuleßa on 09.03.22.
//

import Foundation
import PDFKit
import CovPassCommon

struct RevocationPDFExportData: RevocationPDFExportDataProtocol {
    let fileURL: URL
    private let pdfDocument: PDFDocument
    private let fileManager: FileManager

    init(pdfDocument: PDFDocument,
         issuingCountry: String,
         transactionNumber: String,
         date: Date,
         fileManager: FileManager) {
        self.pdfDocument = pdfDocument
        self.fileManager = fileManager
        let date = DateUtils.dayMonthYearDateFormatter.string(from: date)
        let filename = "\(transactionNumber)_\(issuingCountry)_\(date).pdf"
        fileURL = fileManager.temporaryDirectory.appendingPathComponent(filename)
    }

    func write() {
        pdfDocument.write(to: fileURL)
    }

    func delete() throws {
        try fileManager.removeItem(at: self.fileURL)
    }
}
