//
//  CertificateReissueRepositoryMock.swift
//  
//
//  Created by Thomas Kuleßa on 17.02.22.
//

import PromiseKit

public class CertificateReissueRepositoryMock: CertificateReissueRepositoryProtocol {
    var reissueResponse: CertificateReissueRepositoryResponse = []
    var error: CertificateReissueError?
    public func reissue(_ cborWebTokens: [String]) -> Promise<CertificateReissueRepositoryResponse> {
        if let error = error {
            return .init(error: error)
        }
        return .value(reissueResponse)
    }
}
