//
//  DCCService.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import PromiseKit
import CertLogic

public protocol DCCServiceProtocol {
    func loadDCCRules() -> Promise<[RuleSimple]>
    func loadDCCRule(country: String, hash: String) -> Promise<Rule>
}

public enum DCCServiceError: Error {
    case invalidURL
}

public struct DCCService: DCCServiceProtocol {
    private let url: URL

    public init(url: URL) {
        self.url = url
    }

    public func loadDCCRules() -> Promise<[RuleSimple]> {
        return Promise { seal in
            guard let url = URL(string: "\(url.absoluteString)/rules") else {
                seal.reject(DCCServiceError.invalidURL)
                return
            }
            let data = try Data(contentsOf: url)
            let res = try JSONDecoder().decode([RuleSimple].self, from: data)
            seal.fulfill(res)
        }
    }

    public func loadDCCRule(country: String, hash: String) -> Promise<Rule> {
        return Promise { seal in
            guard let url = URL(string: "\(url.absoluteString)/rules/\(country)/\(hash)") else {
                seal.reject(DCCServiceError.invalidURL)
                return
            }
            let data = try Data(contentsOf: url)
            let res = try JSONDecoder().decode(Rule.self, from: data)
            seal.fulfill(res)
        }
    }
}
