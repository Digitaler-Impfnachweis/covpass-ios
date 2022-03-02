//
//  CertificateReissueRepositoryMock.swift
//  
//
//  Created by Thomas Kuleßa on 17.02.22.
//

import PromiseKit

public class CertificateReissueRepositoryMock: CertificateReissueRepositoryProtocol {
    public var reissueResponse: CertificateReissueRepositoryResponse = []
    public var error: CertificateReissueError?
    public init() {}
    public func reissue(_ cborWebTokens: [ExtendedCBORWebToken]) -> Promise<CertificateReissueRepositoryResponse> {
        if let error = error {
            return .init(error: error)
        }
        return .value(reissueResponse)
    }
}
