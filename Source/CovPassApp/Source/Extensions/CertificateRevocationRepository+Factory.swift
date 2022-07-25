//
//  CertificateRevocationRepository+Factory.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import Foundation

extension CertificateRevocationRepository {
    init?() {
        guard let client = CertificateRevocationHTTPDataSource() else {
            return nil
        }

        self.init(client: client)
    }
}
