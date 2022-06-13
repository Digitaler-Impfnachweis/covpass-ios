//
//  QRCodePDFDocumentError.swift
//  
//
//  Created by Thomas Kuleßa on 08.06.22.
//

import Foundation

public enum QRCodePDFDocumentError: Error {
    /// The page number is out of range.
    case pageNumber(Int)

    /// The file is not a PDF.
    case file(URL)

    /// The PDF page couldn't be converted to an `UIImage` for QR code detection.
    case image
}
