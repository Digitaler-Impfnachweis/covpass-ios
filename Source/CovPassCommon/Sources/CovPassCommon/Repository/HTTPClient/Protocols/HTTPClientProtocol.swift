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
    func httpRequest(_ urlRequest: URLRequest) -> Promise<Data>
}
