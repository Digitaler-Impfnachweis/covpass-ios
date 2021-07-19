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
    case invalidResponse
    case requestCancelled
}

public struct DCCService: DCCServiceProtocol {
    private let url: URL
    private let sessionDelegate: URLSessionDelegate

    public init(url: URL, sessionDelegate: URLSessionDelegate) {
        self.url = url
        self.sessionDelegate = sessionDelegate
    }

    public func loadDCCRules() -> Promise<[RuleSimple]> {
        return Promise { seal in
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
}
