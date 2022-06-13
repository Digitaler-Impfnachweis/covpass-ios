//
//  CertificateReissueRepository+Factory.swift
//  
//
//  Created by Thomas Kuleßa on 18.02.22.
//

import CovPassCommon
import Foundation

public extension CertificateReissueRepository {
    convenience init?() {
        guard let coseSign1MessageConverter = CoseSign1MessageConverter() else {
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
