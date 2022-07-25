//
//  HTTPClientProtocol.swift
//  
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import PromiseKit

/// Wrapper protocol for an URL session. 
public protocol HTTPClientProtocol {
    /// Perfoms a HTTP request.
    /// - Parameter urlRequest: The request to perform.
    /// - Returns: Success if the HTTP status code is is in the range of [200, 299], or if it is 304
    /// (Not modified). In the second case the `data` value of the response object is `nil`.
    func httpRequest(_ urlRequest: URLRequest) -> Promise<HTTPClientResponse>
}
