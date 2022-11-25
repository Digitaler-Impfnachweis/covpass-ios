//
//  QRCodeDocumentProtocol.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

/// Interface for  documents which contain QR codes. E.g. PDF documents or images.
public protocol QRCodeDocumentProtocol {
    /// Number of pages in the document.
    var numberOfPages: Int { get }

    /// Returns the QR codes found on a given page.
    /// - Parameter page: Number of the page. First page is 1.
    /// - Returns: Set of unique QR codes. Throws an error, if page is out of range or an error occured
    ///            during QR code detection.
    func qrCodes(on page: Int) throws -> Set<String>
}
