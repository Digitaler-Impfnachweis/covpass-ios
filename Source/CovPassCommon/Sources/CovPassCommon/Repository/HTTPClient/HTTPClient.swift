//
//  HTTPClient.swift
//  
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import PromiseKit
import SwiftUI

public class HTTPClient: HTTPClientProtocol {
    private var dataTaskProducer: DataTaskProducerProtocol

    public init(dataTaskProducer: DataTaskProducerProtocol) {
        self.dataTaskProducer = dataTaskProducer
    }

    public func httpRequest(_ urlRequest: URLRequest) -> Promise<HTTPClientResponse> {
        Promise { seal in
            dataTaskProducer
                .dataTask(with: urlRequest) { data, urlResponse, error in
                    self.handleResponse(data, urlResponse, error)
                        .done { data in
                            seal.fulfill(data)
                        }
                        .catch { error in
                            seal.reject(error)
                        }
                }
                .resume()
        }
    }

    private func handleResponse(_ data: Data?, _ urlResponse: URLResponse?, _ error: Error?) -> Promise<HTTPClientResponse> {
        self.checkForNoError(error)
            .then { _ in self.httpURLResponse(from: urlResponse) }
            .then { self.checkHTTPStatusCode(data, response: $0) }
    }

    private func checkForNoError(_ error: Error?) -> Promise<Void> {
        guard let error = error else {
            return .value
        }
        return .init(error: mapIfIsCancelled(error))
    }

    private func mapIfIsCancelled(_ error: Error) -> Error {
        let error = error as NSError
        if error.domain == NSURLErrorDomain, error.isCancelled {
            return HTTPClientError.dataTaskCancelled
        }
        return error
    }

    private func httpURLResponse(from urlResponse: URLResponse?) -> Promise<HTTPURLResponse> {
        guard let httpURLResponse = urlResponse as? HTTPURLResponse else {
            return .init(error: HTTPClientError.invalidResponse(urlResponse))
        }
        return .value(httpURLResponse)
    }

    private func checkHTTPStatusCode(_ data: Data?, response: HTTPURLResponse) -> Promise<HTTPClientResponse> {
        response.isOk ?
            .value(.init(httpURLResponse: response, data: data)) :
            .init(error: HTTPClientError.http(response.statusCode, data: data))
    }
}

private extension HTTPURLResponse {
    var isOk: Bool {
        200 ..< 300 ~= statusCode ||
        HTTPStatusCode.notModified == statusCode
    }
}
