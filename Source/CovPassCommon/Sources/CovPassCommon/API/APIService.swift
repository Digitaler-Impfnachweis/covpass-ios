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

extension URL {
    var urlRequest: URLRequest {
        URLRequest(url: self)
    }
}

extension URLRequest {
    var GET: URLRequest {
        var s = self
        s.httpMethod = "GET"
        return s
    }
}

public protocol CustomURLSessionProtocol {
    func request(_ urlRequest: URLRequest) -> Promise<String>
}

public struct CustomURLSession: CustomURLSessionProtocol {
    let sessionDelegate: URLSessionDelegate

    public init(sessionDelegate: URLSessionDelegate) {
        self.sessionDelegate = sessionDelegate
    }

    public func request(_ urlRequest: URLRequest) -> Promise<String> {
        Promise { seal in
            print(urlRequest.url?.absoluteString ?? "")
            let session = URLSession(configuration: URLSessionConfiguration.ephemeral,
                                     delegate: self.sessionDelegate,
                                     delegateQueue: nil)
            session.dataTask(with: urlRequest) { data, response, error in
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
                   seal.reject(APIError.invalidResponse)
                   return
               }

               guard let data = data, let dataString = String(data: data, encoding: .utf8) else {
                   seal.reject(APIError.invalidResponse)
                   return
               }

               seal.fulfill(dataString)
            }.resume()
       }
    }
}

public struct APIService: APIServiceProtocol {
    private let url: String
    private let contentType: String = "application/cbor+base45"
    private let customURLSession: CustomURLSessionProtocol

    public init(customURLSession: CustomURLSessionProtocol, url: String) {
        self.customURLSession = customURLSession
        self.url = url
    }

    public func fetchTrustList() -> Promise<String> {
        guard let requestUrl = URL(string: url) else {
            return Promise(error: APIError.invalidUrl)
        }
        return customURLSession.request(requestUrl.urlRequest.GET)
    }
}
