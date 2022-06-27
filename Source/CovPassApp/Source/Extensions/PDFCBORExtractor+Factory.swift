//
//  PDFCBORExtractor+Factory.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import CovPassCommon

extension PDFCBORExtractor {
    convenience init?() {
        guard let messageConverter = CoseSign1MessageConverter(),
              let revocationRepository = CertificateRevocationRepository()
        else {
            return nil
        }
        let maximalNumberOfTokens = 100
        let queue = DispatchQueue.global()

        self.init(
            maximalNumberOfTokens: maximalNumberOfTokens,
            coseSign1MessageConverter: messageConverter,
            revocationRepository: revocationRepository,
            queue: queue
        )
    }
}
