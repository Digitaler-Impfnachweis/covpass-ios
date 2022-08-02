//
//  CertificateRevocationFilesystemDataSource+Factory.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import Foundation

private enum Constants {
    static let path = "revocation-data/"
}

extension CertificateRevocationFilesystemDataSource {
    convenience init?() {
        let fileManager = FileManager.default
        guard let bundleID = Bundle.main.bundleIdentifier,
              let applicationSupportURL = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
        else {
            return nil
        }
        let baseURL = applicationSupportURL
            .appendingPathComponent(bundleID, isDirectory: true)
            .appendingPathComponent(Constants.path, isDirectory: true)
        
        self.init(
            baseURL: baseURL,
            fileManager: fileManager
        )
    }
}
