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
        let baseURL = XCConfiguration.certificateReissueURL
        let urlSession = CertificateReissueURLSession(
            urlSession: URLSession.certificateReissue()
        )

        self.init(
            baseURL: baseURL,
            jsonDecoder: JSONDecoder(),
            jsonEncoder: JSONEncoder(),
            urlSession: urlSession
        )
    }
}

extension XCConfiguration {
    static var certificateReissueURL: URL {
        Self.value(URL.self, forKey: "CERTIFICATE_REISSUE_URL")
    }
}
