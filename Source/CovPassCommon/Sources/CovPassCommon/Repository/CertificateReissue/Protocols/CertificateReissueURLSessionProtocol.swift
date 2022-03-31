//
//  CertificateReissueURLSessionProtocol.swift
//  
//
//  Created by Thomas Kuleßa on 18.02.22.
//

import Foundation
import PromiseKit

/// Wrapper protocol for an URL session. 
public protocol CertificateReissueURLSessionProtocol {
    func httpRequest(_ urlRequest: URLRequest) -> Promise<Data>
}
