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
    func vaasListOfServices(initialisationData: ValidationServiceInitialisation) -> Promise<String>
    func vaasListOfServices(url: URL) -> Promise<String>
}
