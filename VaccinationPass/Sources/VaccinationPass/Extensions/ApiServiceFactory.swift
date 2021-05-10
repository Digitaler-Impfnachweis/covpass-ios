//
//  ApiServiceFactory.swift
//  
//
//  Copyright © 2021 IBM. All rights reserved.
//

import Foundation
import VaccinationCommon

extension APIService {
    static func create() -> APIService {
        APIService(
            sessionDelegate: APIServiceDelegate(
                certUrl: Bundle.commonBundle.url(forResource: XCConfiguration.value(String.self, forKey: "TLS_CERTIFICATE_NAME"), withExtension: "der")!
            ),
            url: XCConfiguration.value(String.self, forKey: "API_URL")
        )
    }
}
