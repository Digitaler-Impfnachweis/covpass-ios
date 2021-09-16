//
//  WKWebView+PDF.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import PDFKit
import UIKit
import WebKit

extension WKWebView {
    enum PDFRenderError: Error {
        case stillLoading, invalidPDF
    }

    /// Exports a PDF document with this web view current contents.
    /// Only call this function when the web view has **finished** loading.
    func exportAsPDF() throws -> PDFDocument {
        guard isLoading == false else {
            throw PDFRenderError.stillLoading
        }
        let pdfData = createPDFData()
        guard let pdf = PDFDocument(data: pdfData) else {
            throw PDFRenderError.invalidPDF
        }
        return pdf
    }

    private func createPDFData() -> Data {
        // A4 size
        let pageSize = CGSize(width: 595.2, height: 841.8)

        // some sensible margins - mostly to prevent an empty 2nd page in the resulting PDF
        let pageMargins = UIEdgeInsets(top: 24, left: 24, bottom: 24, right: 24)

        // calculate the printable rect from the above two
        let printableRect = CGRect(x: pageMargins.left, y: pageMargins.top, width: pageSize.width - pageMargins.left - pageMargins.right, height: pageSize.height - pageMargins.top - pageMargins.bottom)

        // the overall paper rectangle
        let paperRect = CGRect(x: 0, y: 0, width: pageSize.width, height: pageSize.height)

        let printRenderer = UIPrintPageRenderer()
        printRenderer.addPrintFormatter(viewPrintFormatter(), startingAtPageAt: 0)
        printRenderer.setValue(NSValue(cgRect: paperRect), forKey: "paperRect")
        printRenderer.setValue(NSValue(cgRect: printableRect), forKey: "printableRect")

        return printRenderer.generatePDFData()
    }
}
