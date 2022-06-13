//
//  QRCodeDocumentProtocol.swift
//  
//
//  Created by Thomas Kuleßa on 09.06.22.
//

/// Interface for PDF documents which contain QR codes.
public protocol QRCodePDFDocumentProtocol {
    /// Number of pages in the document.
    var numberOfPages: Int { get }

    /// Returns the QR codes found on a given page.
    /// - Parameter page: Number of the page. First page is 1.
    /// - Returns: Set of unique QR codes. Throws an error, if page is out of range or an error occured
    ///            during QR code detection.
    func qrCodes(on page: Int) throws -> Set<String>
}
