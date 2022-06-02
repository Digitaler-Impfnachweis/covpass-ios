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
    public private(set) var receivedRenewTokens: [ExtendedCBORWebToken] = []
    public private(set) var receivedExtendTokens: [ExtendedCBORWebToken] = []
    public init() {}
    public func renew(_ cborWebTokens: [ExtendedCBORWebToken]) -> Promise<CertificateReissueRepositoryResponse> {
        receivedRenewTokens = cborWebTokens
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
        receivedExtendTokens = webTokens
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
