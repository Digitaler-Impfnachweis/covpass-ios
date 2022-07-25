//
//  HTTPClientMock.swift
//  
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassCommon
import Foundation
import PromiseKit

class HTTPClientMock: HTTPClientProtocol {
    var error: Error?
    var response = HTTPClientResponse(httpURLResponse: .init(), data: nil)
    var receivedHTTPRequest: URLRequest?

    func httpRequest(_ urlRequest: URLRequest) -> Promise<HTTPClientResponse> {
        receivedHTTPRequest = urlRequest
        if let error = error {
            return .init(error: error)
        }
        return .value(response)
    }
}
