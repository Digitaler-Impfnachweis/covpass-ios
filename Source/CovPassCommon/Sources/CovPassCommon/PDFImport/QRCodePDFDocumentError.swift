//
//  QRCodePDFDocumentError.swift
//  
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
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
