//
//  CertificateRevocationWrapperRepository+Factory.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon

extension CertificateRevocationWrapperRepository {
    init?() {
        guard let httpDataSource = CertificateRevocationHTTPDataSource(),
              let filesystemDataSource = CertificateRevocationFilesystemDataSource()
        else {
            return nil
        }
        let localRepository = CertificateRevocationRepository(client: filesystemDataSource)
        let remoteRepostory = CertificateRevocationRepository(client: httpDataSource)
        let persistence = UserDefaultsPersistence()

        self.init(
            localRepository: localRepository,
            remoteRepostory: remoteRepostory,
            persistence: persistence
        )
    }
}
