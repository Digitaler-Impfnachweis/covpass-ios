//
//  RevokeUseCase.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import PromiseKit
import Foundation

public struct RevokeUseCase {
    private let token: ExtendedCBORWebToken
    private let revocationRepository: CertificateRevocationRepositoryProtocol
    
    public init(token: ExtendedCBORWebToken,
                revocationRepository: CertificateRevocationRepositoryProtocol) {
        self.token = token
        self.revocationRepository = revocationRepository
    }
    
    public func execute() -> Promise<ExtendedCBORWebToken> {
        isRevoked(token)
    }
    
    private func isRevoked(_ token: ExtendedCBORWebToken) -> Promise<ExtendedCBORWebToken> {
        firstly {
            revocationRepository.isRevoked(token)
        }
        .then(on: .global()) { isRevoked -> Promise<ExtendedCBORWebToken> in
            if isRevoked {
                return .init(error: CertificateError.revoked(token))
            }
            return .value(token)
        }
    }
}
