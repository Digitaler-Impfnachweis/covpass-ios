//
//  CertificateReissueRepository+Factory.swift
//  
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import Foundation

public extension CertificateReissueRepository {
    convenience init?() {
        guard let coseSign1MessageConverter = CoseSign1MessageConverter.certificateReissueRepository() else {
            return nil
        }
        let jsonDecoder = JSONDecoder()
        let jsonEncoder = JSONEncoder()
        let baseURL = XCConfiguration.certificateReissueURL
        let dataTaskProducer = DataTaskProducer(
            urlSession:URLSession.certificateReissue()
        )
        let httpClient = HTTPClient(
            dataTaskProducer: dataTaskProducer
        )

        self.init(
            baseURL: baseURL,
            jsonDecoder: jsonDecoder,
            jsonEncoder: jsonEncoder,
            httpClient: httpClient,
            coseSign1MessageConverter: coseSign1MessageConverter
        )
    }
}
