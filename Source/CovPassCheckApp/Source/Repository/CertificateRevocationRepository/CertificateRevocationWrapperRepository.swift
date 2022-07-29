//
//  CertificateRevocationWrapperRepository.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import PromiseKit

/// Revocation repository that wraps a local, filesystem base repository and a remotr HTTP based repository.
/// Based on a `Persistence` backed key it's decided which one to use.
struct CertificateRevocationWrapperRepository: CertificateRevocationRepositoryProtocol {
    private let localRepository: CertificateRevocationRepositoryProtocol
    private let remoteRepository: CertificateRevocationRepositoryProtocol
    private let persistence: Persistence

    init(localRepository: CertificateRevocationRepositoryProtocol,
         remoteRepostory: CertificateRevocationRepositoryProtocol,
         persistence: Persistence
    ) {
        self.localRepository = localRepository
        self.remoteRepository = remoteRepostory
        self.persistence = persistence
    }

    func isRevoked(_ webToken: ExtendedCBORWebToken) -> Guarantee<Bool> {
        let repository = persistence.isCertificateRevocationOfflineServiceEnabled ? localRepository : remoteRepository
        return repository.isRevoked(webToken)
    }
}
