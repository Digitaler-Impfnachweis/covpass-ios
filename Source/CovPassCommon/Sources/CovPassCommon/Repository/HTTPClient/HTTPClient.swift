//
//  HTTPClient.swift
//  
//
//  Created by Thomas Kuleßa on 18.02.22.
//

import Foundation
import PromiseKit
import SwiftUI

public class HTTPClient: HTTPClientProtocol {
    private var dataTaskProducer: DataTaskProducerProtocol

    public init(dataTaskProducer: DataTaskProducerProtocol) {
        self.dataTaskProducer = dataTaskProducer
    }

    public func httpRequest(_ urlRequest: URLRequest) -> Promise<Data> {
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

    private func handleResponse(_ data: Data?, _ urlResponse: URLResponse?, _ error: Error?) -> Promise<Data> {
        self.checkForNoError(error)
            .then { _ in self.httpURLResponse(from: urlResponse) }
            .then { self.checkHTTPStatusCode(data, response: $0) }
            .then { _ -> Promise<Data> in
                if let data = data {
                    return .value(data)
                }
                return .init(error: HTTPClientError.invalidResponse(urlResponse))
            }
    }

    private func checkForNoError(_ error: Error?) -> Promise<Void> {
        guard let error = error else {
            return .value
        }
        return .init(error: error)
    }

    private func httpURLResponse(from urlResponse: URLResponse?) -> Promise<HTTPURLResponse> {
        guard let httpURLResponse = urlResponse as? HTTPURLResponse else {
            return .init(error: HTTPClientError.invalidResponse(urlResponse))
        }
        return .value(httpURLResponse)
    }

    private func checkHTTPStatusCode(_ data: Data?, response: HTTPURLResponse) -> Promise<Data?> {
        response.isOk ?
            .value(data) :
            .init(error: HTTPClientError.http(response.statusCode, data: data))
    }
}

private extension HTTPURLResponse {
    var isOk: Bool {
        200 ..< 300 ~= statusCode
    }
}
