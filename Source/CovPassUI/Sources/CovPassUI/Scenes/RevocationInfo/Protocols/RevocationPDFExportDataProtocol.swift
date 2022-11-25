//
//  RevocationPDFExportDataProtocol.swift.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
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
