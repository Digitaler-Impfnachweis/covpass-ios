//
//  APIServiceProtocol.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import PromiseKit

public protocol APIServiceProtocol {
    func fetchTrustList() -> Promise<String>
    func vaasListOfServices(url: URL) -> Promise<String>
    func getAccessTokenFor(url: URL, servicePath: String, publicKey: String, ticketToken: String) -> Promise<String>
    func validateTicketing(url: URL, parameters: [String: String]?, accessToken: String) -> Promise<String>
    func cancellTicket(url: URL, ticketToken: String) -> Promise<String>
}
