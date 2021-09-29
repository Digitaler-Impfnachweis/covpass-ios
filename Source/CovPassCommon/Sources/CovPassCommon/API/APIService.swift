//
//  APIService.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import PromiseKit
import SwiftCBOR

public struct APIService: APIServiceProtocol {
    private let url: String
    private let boosterURL: String
    private let contentType: String = "application/cbor+base45"
    private let sessionDelegate: URLSessionDelegate

    public init(sessionDelegate: URLSessionDelegate, url: String, boosterURL: String) {
        self.sessionDelegate = sessionDelegate
        self.url = url
        self.boosterURL = boosterURL
    }

    public func fetchTrustList() -> Promise<String> {
        return Promise { seal in
            guard let requestUrl = URL(string: url) else {
                seal.reject(APIError.invalidUrl)
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
                        seal.reject(APIError.requestCancelled)
                        return
                    }
                    if let error = error as? URLError, error.isCancelled {
                        seal.reject(APIError.requestCancelled)
                        return
                    }
                    seal.reject(error)
                    return
                }
                guard let response = response as? HTTPURLResponse else {
                    seal.reject(APIError.invalidResponse)
                    return
                }
                guard (200 ... 299).contains(response.statusCode) else {
                    print(String(data: data ?? Data(), encoding: .utf8) ?? "")
                    seal.reject(APIError.invalidResponse)
                    return
                }

                guard let data = data, let trustListResponse = String(data: data, encoding: .utf8) else {
                    seal.reject(APIError.invalidResponse)
                    return
                }

                seal.fulfill(trustListResponse)
            }.resume()
        }
    }
}
