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
                            seal.reject(error.certificateReissueError())
                        }
                }
                .resume()
        }
    }

    private func handleResponse(_ data: Data?, _ urlResponse: URLResponse?, _ error: Error?) -> Promise<Data> {
        self.checkForNoError(error)
            .then { _ in self.httpURLResponse(from: urlResponse) }
            .then(\.isOk)
            .then { _ -> Promise<Data> in
                if let data = data {
                    return .value(data)
                }
                return .init(error: APIError.invalidResponse)
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
            return .init(error: APIError.invalidResponse)
        }
        return .value(httpURLResponse)
    }
}

private extension Error {
    func certificateReissueError() -> CertificateReissueError {
        switch self {
        case let error as APIError:
            return .api(error)
        case let error as CertificateReissueError:
            return error
        default:
            return .other(self)
        }
    }
}

private extension HTTPURLResponse {
    var isOk: Promise<Void> {
        guard 200 ..< 300 ~= statusCode else {
            return .init(error: CertificateReissueError.http(statusCode))
        }
        return .value
    }
}
