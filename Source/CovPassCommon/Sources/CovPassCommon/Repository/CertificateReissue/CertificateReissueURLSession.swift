//
//  CertificateReissueURLSession.swift
//  
//
//  Created by Thomas Kuleßa on 18.02.22.
//

import Foundation
import PromiseKit
import SwiftUI

public class CertificateReissueURLSession: CertificateReissueURLSessionProtocol {
    private var urlSession: URLSession

    public init(urlSession: URLSession) {
        self.urlSession = urlSession
    }

    public func httpRequest(_ urlRequest: URLRequest) -> Promise<Data> {
        Promise { seal in
            urlSession
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
                return .init(error: CertificateReissueURLSesssionError.invalidResponse(urlResponse))
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
            return .init(error: CertificateReissueURLSesssionError.invalidResponse(urlResponse))
        }
        return .value(httpURLResponse)
    }

    private func checkHTTPStatusCode(_ data: Data?, response: HTTPURLResponse) -> Promise<Data?> {
        response.isOk ?
            .value(data) :
            .init(error: CertificateReissueURLSesssionError.http(response.statusCode, data: data))
    }
}

private extension HTTPURLResponse {
    var isOk: Bool {
        200 ..< 300 ~= statusCode
    }
}
