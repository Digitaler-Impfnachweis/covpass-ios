//
//  RevocationInfoRouterProtocol.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import PDFKit

public protocol RevocationInfoRouterProtocol {
    func showPDFExport(with exportData: RevocationPDFExportDataProtocol)
}
