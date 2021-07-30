//
//  WKWebView+PDF.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import UIKit
import WebKit
import PDFKit

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
        #warning("paper size, etc. needs fine tuning!")
        let oldBounds = bounds

        var printBounds = bounds
        printBounds.size.height = scrollView.contentSize.height
        bounds = printBounds

        var printableRect = printBounds
        printableRect.origin = .zero

        let printRenderer = UIPrintPageRenderer()
        printRenderer.addPrintFormatter(viewPrintFormatter(), startingAtPageAt: 0)
        // via: https://www.cl.cam.ac.uk/~mgk25/iso-paper-ps.txt
        printRenderer.setValue(NSValue(cgRect: CGRect(x: 0, y: 0, width: 595, height: 842)), forKey: "paperRect")
        printRenderer.setValue(NSValue(cgRect: printableRect), forKey: "printableRect")

        bounds = oldBounds
        return printRenderer.generatePDFData()
    }
}
