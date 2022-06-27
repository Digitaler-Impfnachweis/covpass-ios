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
    var data = Data()
    var receivedHTTPRequest: URLRequest?

    func httpRequest(_ urlRequest: URLRequest) -> Promise<Data> {
        receivedHTTPRequest = urlRequest
        if let error = error {
            return .init(error: error)
        }
        return .value(data)
    }
}
