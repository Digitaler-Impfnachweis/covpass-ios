//
//  UIPrintPageRenderer+PDF.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import UIKit

extension UIPrintPageRenderer {

    func generatePDFData() -> Data {
        let pdfData = NSMutableData()
        UIGraphicsBeginPDFContextToData(pdfData, paperRect, nil)
        prepare(forDrawingPages: NSMakeRange(0, numberOfPages))
        let printRect = UIGraphicsGetPDFContextBounds()

        for pdfPage in 0..<numberOfPages {
            UIGraphicsBeginPDFPage()
            drawPage(at: pdfPage, in: printRect)
        }

        UIGraphicsEndPDFContext()
        return pdfData as Data
    }
}
