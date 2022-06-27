//
//  ShareRevocationPDFViewModel.swift
//  
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation

struct ShareRevocationPDFViewModel: ShareRevocationPDFViewModelProtocol {
    let fileURL: URL
    private let exportData: RevocationPDFExportDataProtocol

    init(exportData: RevocationPDFExportDataProtocol) {
        self.exportData = exportData
        self.fileURL = exportData.fileURL
        exportData.write()
    }

    func handleActivityResult(completed: Bool, activityError: Error?) {
        if let error = activityError {
            print("Failed to share revocation PDF: \(error)")
        }
        do {
            try exportData.delete()
        } catch {
            assertionFailure("Unexpected error while deleting revocation PDF: \(error)")
        }
    }
}
