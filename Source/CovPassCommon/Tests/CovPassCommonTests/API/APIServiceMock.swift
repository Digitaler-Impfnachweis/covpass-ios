//
//  APIServiceMock.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import PromiseKit

@testable import CovPassCommon

class APIServiceMock: APIServiceProtocol {
    
    var vaasListOfServicesResponse: Promise<String>?
    func vaasListOfServices(url: URL) -> Promise<String> {
        vaasListOfServicesResponse ?? Promise.value("")
    }
    
    var accesTokenResponse: Promise<String>?
    func getAccessTokenFor(url: URL, servicePath: String, publicKey: String) -> Promise<String> {
        accesTokenResponse ?? Promise.value("")
    }
    
    var trustListResult: Promise<String>?
    func fetchTrustList() -> Promise<String> {
        trustListResult ?? Promise.value("")
    }
}
