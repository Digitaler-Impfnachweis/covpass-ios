//
//  RevocationPDFExportDataProtocol.swift.swift
//  
//
//  Created by Thomas Kuleßa on 10.03.22.
//

import Foundation

public protocol RevocationPDFExportDataProtocol {
    /// URL for the PDF document.
    var fileURL: URL { get }

    /// Writes the revocation PDF to `fileURL`.
    func write()

    /// Delete the file at `fileURL`.
    func delete() throws
}
