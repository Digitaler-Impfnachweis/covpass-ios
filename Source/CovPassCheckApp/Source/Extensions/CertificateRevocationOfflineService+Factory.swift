//
//  CertificateRevocationOfflineService+Factory.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import Foundation

extension CertificateRevocationOfflineService {
    static let shared = CertificateRevocationOfflineService()

    convenience init?() {
        guard let localDataSource = CertificateRevocationFilesystemDataSource(),
              let remoteDataSource = CertificateRevocationHTTPDataSource() else {
            return nil
        }
        let dateProvider = DateProvider()
        let persistence = UserDefaultsPersistence()

        self.init(
            localDataSource: localDataSource,
            remoteDataSource: remoteDataSource,
            dateProvider: dateProvider,
            persistence: persistence
        )
    }
}
