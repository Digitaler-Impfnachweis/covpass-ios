//
//  DCCService.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CertLogic
import Foundation
import PromiseKit

public protocol DCCServiceProtocol {
    func loadDCCRules() -> Promise<[RuleSimple]>
    func loadDCCRule(country: String, hash: String) -> Promise<Rule>

    func loadValueSets() -> Promise<[[String: String]]>
    func loadValueSet(id: String, hash: String) -> Promise<ValueSet>

    func loadBoosterRules() -> Promise<[RuleSimple]>
    func loadBoosterRule(hash: String) -> Promise<Rule>

    func loadDomesticRules() -> Promise<[RuleSimple]>
    func loadDomesticRule(hash: String) -> Promise<Rule>

    func loadCountryList() -> Promise<[Country]>
}

public enum DCCServiceError: Error, ErrorCode {
    case invalidURL
    case invalidResponse
    case requestCancelled

    public var errorCode: Int {
        switch self {
        case .requestCancelled:
            return 101
        case .invalidURL:
            return 103
        case .invalidResponse:
            return 104
        }
    }
}

public struct DCCService: DCCServiceProtocol {
    private let url: URL
    private let boosterURL: URL
    private let domesticURL: URL
    private let customURLSession: CustomURLSessionProtocol

    public init(url: URL,
                boosterURL: URL,
                domesticURL: URL,
                customURLSession: CustomURLSessionProtocol) {
        self.url = url
        self.boosterURL = boosterURL
        self.domesticURL = domesticURL
        self.customURLSession = customURLSession
    }

    public func loadDCCRules() -> Promise<[RuleSimple]> {
        guard let requestUrl = URL(string: "\(url.absoluteString)/rules") else {
            return Promise(error: APIError.invalidUrl)
        }
        return customURLSession
            .request(requestUrl.urlRequest.GET)
            .map(on: .global()) { response in
                guard let data = response.data(using: .utf8), let res = try? JSONDecoder().decode([RuleSimple].self, from: data) else {
                    throw DCCServiceError.invalidResponse
                }
                return res
            }
    }

    public func loadDCCRule(country: String, hash: String) -> Promise<Rule> {
        guard let requestUrl = URL(string: "\(url.absoluteString)/rules/\(country)/\(hash)") else {
            return Promise(error: APIError.invalidUrl)
        }
        return customURLSession
            .request(requestUrl.urlRequest.GET)
            .map(on: .global()) { response in
                guard let data = response.data(using: .utf8), let res = try? JSONDecoder().decode(Rule.self, from: data) else {
                    throw DCCServiceError.invalidResponse
                }
                res.hash = hash
                return res
            }
    }

    public func loadValueSets() -> Promise<[[String: String]]> {
        guard let requestUrl = URL(string: "\(url.absoluteString)/valuesets") else {
            return Promise(error: APIError.invalidUrl)
        }
        return customURLSession
            .request(requestUrl.urlRequest.GET)
            .map(on: .global()) { response in
                guard let data = response.data(using: .utf8), let res = try? JSONDecoder().decode([[String: String]].self, from: data) else {
                    throw DCCServiceError.invalidResponse
                }
                return res
            }
    }

    public func loadValueSet(id: String, hash: String) -> Promise<ValueSet> {
        guard let requestUrl = URL(string: "\(url.absoluteString)/valuesets/\(hash)") else {
            return Promise(error: APIError.invalidUrl)
        }
        return customURLSession
            .request(requestUrl.urlRequest.GET)
            .map(on: .global()) { response in
                guard let data = response.data(using: .utf8) else {
                    throw DCCServiceError.invalidResponse
                }
                return ValueSet(id: id, hash: hash, data: data)
            }
    }

    public func loadBoosterRules() -> Promise<[RuleSimple]> {
        guard let requestUrl = URL(string: "\(boosterURL.absoluteString)") else {
            return Promise(error: APIError.invalidUrl)
        }
        return customURLSession
            .request(requestUrl.urlRequest.GET)
            .map(on: .global()) { response in
                guard let data = response.data(using: .utf8), let res = try? JSONDecoder().decode([RuleSimple].self, from: data) else {
                    throw DCCServiceError.invalidResponse
                }
                return res
            }
    }

    public func loadBoosterRule(hash: String) -> Promise<Rule> {
        customURLSession
            .request(boosterURL.appendingPathComponent(hash).urlRequest.GET)
            .map(on: .global()) { response in
                guard let data = response.data(using: .utf8), let res = try? JSONDecoder().decode(Rule.self, from: data) else {
                    throw DCCServiceError.invalidResponse
                }
                res.hash = hash
                return res
            }
    }

    public func loadDomesticRules() -> Promise<[RuleSimple]> {
        guard let requestUrl = URL(string: "\(domesticURL.absoluteString)") else {
            return Promise(error: APIError.invalidUrl)
        }
        return customURLSession
            .request(requestUrl.urlRequest.GET)
            .map(on: .global()) { response in
                guard let data = response.data(using: .utf8), let res = try? JSONDecoder().decode([RuleSimple].self, from: data) else {
                    throw DCCServiceError.invalidResponse
                }
                return res
            }
    }

    public func loadDomesticRule(hash: String) -> Promise<Rule> {
        customURLSession
            .request(domesticURL.appendingPathComponent(hash).urlRequest.GET)
            .map(on: .global()) { response in
                guard let data = response.data(using: .utf8), let res = try? JSONDecoder().decode(Rule.self, from: data) else {
                    throw DCCServiceError.invalidResponse
                }
                res.hash = hash
                return res
            }
    }

    public func loadCountryList() -> Promise<[Country]> {
        guard let requestUrl = URL(string: "\(url.absoluteString)/countrylist") else {
            return Promise(error: APIError.invalidUrl)
        }
        return customURLSession
            .request(requestUrl.urlRequest.GET)
            .map(on: .global()) { response in
                guard let data = response.data(using: .utf8),
                      let saveURL = Countries.downloadURL,
                      let countries: [Country] = try? JSONDecoder().decode([String].self, from: data).map({ .init($0) }) else {
                    throw DCCServiceError.invalidResponse
                }
                try data.write(to: saveURL)
                return countries
            }
    }
}
