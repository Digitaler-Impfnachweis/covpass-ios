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
    func loadBoosterRule(country: String, hash: String) -> Promise<Rule>
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
    private let sessionDelegate: URLSessionDelegate

    public init(url: URL, boosterURL: URL, sessionDelegate: URLSessionDelegate) {
        self.url = url
        self.boosterURL = boosterURL
        self.sessionDelegate = sessionDelegate
    }

    public func loadDCCRules() -> Promise<[RuleSimple]> {
        return Promise { seal in
            print("\(url.absoluteString)/rules")
            guard let requestUrl = URL(string: "\(url.absoluteString)/rules") else {
                seal.reject(DCCServiceError.invalidURL)
                return
            }
            var request = URLRequest(url: requestUrl)
            request.httpMethod = "GET"

            let session = URLSession(configuration: URLSessionConfiguration.ephemeral,
                                     delegate: self.sessionDelegate,
                                     delegateQueue: nil)

            session.dataTask(with: request) { data, response, error in
                if let error = error {
                    if let error = error as NSError?, error.code == NSURLErrorCancelled {
                        seal.reject(DCCServiceError.requestCancelled)
                        return
                    }
                    if let error = error as? URLError, error.isCancelled {
                        seal.reject(DCCServiceError.requestCancelled)
                        return
                    }
                    seal.reject(error)
                    return
                }
                guard let response = response as? HTTPURLResponse else {
                    seal.reject(DCCServiceError.invalidResponse)
                    return
                }
                guard (200 ... 299).contains(response.statusCode) else {
                    print(String(data: data ?? Data(), encoding: .utf8) ?? "")
                    seal.reject(DCCServiceError.invalidResponse)
                    return
                }

                guard let data = data, let res = try? JSONDecoder().decode([RuleSimple].self, from: data) else {
                    seal.reject(DCCServiceError.invalidResponse)
                    return
                }

                seal.fulfill(res)
            }.resume()
        }
    }

    public func loadDCCRule(country: String, hash: String) -> Promise<Rule> {
        return Promise { seal in
            print("\(url.absoluteString)/rules/\(country)/\(hash)")
            guard let requestUrl = URL(string: "\(url.absoluteString)/rules/\(country)/\(hash)") else {
                seal.reject(DCCServiceError.invalidURL)
                return
            }
            var request = URLRequest(url: requestUrl)
            request.httpMethod = "GET"

            let session = URLSession(configuration: URLSessionConfiguration.ephemeral,
                                     delegate: self.sessionDelegate,
                                     delegateQueue: nil)

            session.dataTask(with: request) { data, response, error in
                if let error = error {
                    if let error = error as NSError?, error.code == NSURLErrorCancelled {
                        seal.reject(DCCServiceError.requestCancelled)
                        return
                    }
                    if let error = error as? URLError, error.isCancelled {
                        seal.reject(DCCServiceError.requestCancelled)
                        return
                    }
                    seal.reject(error)
                    return
                }
                guard let response = response as? HTTPURLResponse else {
                    seal.reject(DCCServiceError.invalidResponse)
                    return
                }
                guard (200 ... 299).contains(response.statusCode) else {
                    print(String(data: data ?? Data(), encoding: .utf8) ?? "")
                    seal.reject(DCCServiceError.invalidResponse)
                    return
                }

                guard let data = data, let res = try? JSONDecoder().decode(Rule.self, from: data) else {
                    seal.reject(DCCServiceError.invalidResponse)
                    return
                }
                res.hash = hash

                seal.fulfill(res)
            }.resume()
        }
    }

    public func loadValueSets() -> Promise<[[String: String]]> {
        return Promise { seal in
            print("\(url.absoluteString)/valuesets")
            guard let requestUrl = URL(string: "\(url.absoluteString)/valuesets") else {
                seal.reject(DCCServiceError.invalidURL)
                return
            }
            var request = URLRequest(url: requestUrl)
            request.httpMethod = "GET"

            let session = URLSession(configuration: URLSessionConfiguration.ephemeral,
                                     delegate: self.sessionDelegate,
                                     delegateQueue: nil)

            session.dataTask(with: request) { data, response, error in
                if let error = error {
                    if let error = error as NSError?, error.code == NSURLErrorCancelled {
                        seal.reject(DCCServiceError.requestCancelled)
                        return
                    }
                    if let error = error as? URLError, error.isCancelled {
                        seal.reject(DCCServiceError.requestCancelled)
                        return
                    }
                    seal.reject(error)
                    return
                }
                guard let response = response as? HTTPURLResponse else {
                    seal.reject(DCCServiceError.invalidResponse)
                    return
                }
                guard (200 ... 299).contains(response.statusCode) else {
                    print(String(data: data ?? Data(), encoding: .utf8) ?? "")
                    seal.reject(DCCServiceError.invalidResponse)
                    return
                }

                guard let data = data, let res = try? JSONDecoder().decode([[String: String]].self, from: data) else {
                    seal.reject(DCCServiceError.invalidResponse)
                    return
                }

                seal.fulfill(res)
            }.resume()
        }
    }

    public func loadValueSet(id: String, hash: String) -> Promise<ValueSet> {
        return Promise { seal in
            print("\(url.absoluteString)/valuesets/\(hash)")
            guard let requestUrl = URL(string: "\(url.absoluteString)/valuesets/\(hash)") else {
                seal.reject(DCCServiceError.invalidURL)
                return
            }
            var request = URLRequest(url: requestUrl)
            request.httpMethod = "GET"

            let session = URLSession(configuration: URLSessionConfiguration.ephemeral,
                                     delegate: self.sessionDelegate,
                                     delegateQueue: nil)

            session.dataTask(with: request) { data, response, error in
                if let error = error {
                    if let error = error as NSError?, error.code == NSURLErrorCancelled {
                        seal.reject(DCCServiceError.requestCancelled)
                        return
                    }
                    if let error = error as? URLError, error.isCancelled {
                        seal.reject(DCCServiceError.requestCancelled)
                        return
                    }
                    seal.reject(error)
                    return
                }
                guard let response = response as? HTTPURLResponse else {
                    seal.reject(DCCServiceError.invalidResponse)
                    return
                }
                guard (200 ... 299).contains(response.statusCode) else {
                    print(String(data: data ?? Data(), encoding: .utf8) ?? "")
                    seal.reject(DCCServiceError.invalidResponse)
                    return
                }

                guard let data = data else {
                    seal.reject(DCCServiceError.invalidResponse)
                    return
                }

                seal.fulfill(ValueSet(id: id, hash: hash, data: data))
            }.resume()
        }
    }

    public func loadBoosterRules() -> Promise<[RuleSimple]> {
        return Promise { seal in
            guard let requestUrl = URL(string: "\(boosterURL.absoluteString)") else {
                seal.reject(DCCServiceError.invalidURL)
                return
            }
            var request = URLRequest(url: requestUrl)
            request.httpMethod = "GET"

            let session = URLSession(configuration: URLSessionConfiguration.ephemeral,
                                     delegate: self.sessionDelegate,
                                     delegateQueue: nil)

            session.dataTask(with: request) { data, response, error in
                if let error = error {
                    if let error = error as NSError?, error.code == NSURLErrorCancelled {
                        seal.reject(DCCServiceError.requestCancelled)
                        return
                    }
                    if let error = error as? URLError, error.isCancelled {
                        seal.reject(DCCServiceError.requestCancelled)
                        return
                    }
                    seal.reject(error)
                    return
                }
                guard let response = response as? HTTPURLResponse else {
                    seal.reject(DCCServiceError.invalidResponse)
                    return
                }
                guard (200 ... 299).contains(response.statusCode) else {
                    print(String(data: data ?? Data(), encoding: .utf8) ?? "")
                    seal.reject(DCCServiceError.invalidResponse)
                    return
                }

                guard let data = data, let res = try? JSONDecoder().decode([RuleSimple].self, from: data) else {
                    seal.reject(DCCServiceError.invalidResponse)
                    return
                }

                seal.fulfill(res)
            }.resume()
        }
    }

    public func loadBoosterRule(country: String, hash: String) -> Promise<Rule> {
        return Promise { seal in
            guard let requestUrl = URL(string: "\(boosterURL.absoluteString)/\(hash)") else {
                seal.reject(DCCServiceError.invalidURL)
                return
            }
            var request = URLRequest(url: requestUrl)
            request.httpMethod = "GET"

            let session = URLSession(configuration: URLSessionConfiguration.ephemeral,
                                     delegate: self.sessionDelegate,
                                     delegateQueue: nil)

            session.dataTask(with: request) { data, response, error in
                if let error = error {
                    if let error = error as NSError?, error.code == NSURLErrorCancelled {
                        seal.reject(DCCServiceError.requestCancelled)
                        return
                    }
                    if let error = error as? URLError, error.isCancelled {
                        seal.reject(DCCServiceError.requestCancelled)
                        return
                    }
                    seal.reject(error)
                    return
                }
                guard let response = response as? HTTPURLResponse else {
                    seal.reject(DCCServiceError.invalidResponse)
                    return
                }
                guard (200 ... 299).contains(response.statusCode) else {
                    print(String(data: data ?? Data(), encoding: .utf8) ?? "")
                    seal.reject(DCCServiceError.invalidResponse)
                    return
                }

                guard let data = data, let res = try? JSONDecoder().decode(Rule.self, from: data) else {
                    seal.reject(DCCServiceError.invalidResponse)
                    return
                }
                res.hash = hash

                seal.fulfill(res)
            }.resume()
        }
    }
}
