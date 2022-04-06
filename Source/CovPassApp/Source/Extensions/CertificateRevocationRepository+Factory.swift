//
//  CertificateRevocationRepository+Factory.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import Foundation

extension CertificateRevocationRepository {
    convenience init?() {
        let trustKeyResourceName = XCConfiguration.certificateRevocationTrustKey
        guard let trustKeyString = try? Bundle.main.loadString(resource: trustKeyResourceName, encoding: .ascii),
              let secKey = try? trustKeyString.secKey() else {
            return nil
        }
        let url = XCConfiguration.certificateRevocationURL
        let urlSession = URLSession.certificateRevocation()
        let dataTaskProducer = DataTaskProducer(urlSession: urlSession)
        let httpClient = HTTPClient(dataTaskProducer: dataTaskProducer)
        let client = CertificateRevocationHTTPClient(
            baseURL: url,
            httpClient: httpClient,
            secKey: secKey
        )

        self.init(client: client)
    }
}
