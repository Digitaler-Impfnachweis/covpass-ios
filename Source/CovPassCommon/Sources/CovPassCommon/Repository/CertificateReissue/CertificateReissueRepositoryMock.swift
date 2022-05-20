//
//  CertificateReissueRepositoryMock.swift
//  
//
//  Created by Thomas Kuleßa on 17.02.22.
//

import PromiseKit
import Foundation

public class CertificateReissueRepositoryMock: CertificateReissueRepositoryProtocol {
    public var reissueResponse: CertificateReissueRepositoryResponse = []
    public var error: Error?
    public var responseDelay: TimeInterval = 0.0
    public init() {}
    public func renew(_ cborWebTokens: [ExtendedCBORWebToken]) -> Promise<CertificateReissueRepositoryResponse> {
        if let error = error {
            return after(seconds: responseDelay).then {
                Promise.init(error: error)
            }
        }
        return after(seconds: responseDelay).then {
            Promise.value(self.reissueResponse)
        }
    }
    
    public func extend(_ webTokens: [ExtendedCBORWebToken]) -> Promise<CertificateReissueRepositoryResponse> {
        if let error = error {
            return after(seconds: responseDelay).then {
                Promise.init(error: error)
            }
        }
        return after(seconds: responseDelay).then {
            Promise.value(self.reissueResponse)
        }
    }
}
