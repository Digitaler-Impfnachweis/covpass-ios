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
    func vaasListOfServices(url _: URL) -> Promise<String> {
        vaasListOfServicesResponse ?? Promise.value("")
    }

    var accesTokenResponse: Promise<String>?
    func getAccessTokenFor(url _: URL, servicePath _: String, publicKey _: String) -> Promise<String> {
        accesTokenResponse ?? Promise.value("")
    }

    var trustListResult: Promise<String>?
    func fetchTrustList() -> Promise<String> {
        trustListResult ?? Promise.value("")
    }

    func getAccessTokenFor(url _: URL, servicePath _: String, publicKey _: String, ticketToken _: String) -> Promise<String> {
        .value("")
    }

    func validateTicketing(url _: URL, parameters _: [String: String]?, accessToken _: String) -> Promise<String> {
        .value("")
    }

    func cancellTicket(url _: URL, ticketToken _: String) -> Promise<String> {
        .value("")
    }
}
