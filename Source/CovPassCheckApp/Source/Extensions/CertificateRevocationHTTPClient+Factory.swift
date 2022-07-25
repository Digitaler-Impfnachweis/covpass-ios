//
//  CertificateRevocationHTTPClient+Factory.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import Foundation

extension CertificateRevocationHTTPDataSource {
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
        self.init(
            baseURL: url,
            httpClient: httpClient,
            secKey: secKey
        )
    }
}
