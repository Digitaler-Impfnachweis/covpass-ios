//
//  CertificateReissueRepositoryMock.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import PromiseKit

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
                Promise(error: error)
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
                Promise(error: error)
            }
        }
        return after(seconds: responseDelay).then {
            Promise.value(self.reissueResponse)
        }
    }
}
