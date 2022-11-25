//
//  InvalidationUseCase.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import PromiseKit

public class InvalidationUseCase {
    private let certificateList: CertificateList
    private let revocationRepository: CertificateRevocationRepositoryProtocol
    private let vaccinationRepository: VaccinationRepositoryProtocol
    private let date: Date
    private var userDefaults: Persistence

    public init(certificateList: CertificateList,
                revocationRepository: CertificateRevocationRepositoryProtocol,
                vaccinationRepository: VaccinationRepositoryProtocol,
                date: Date,
                userDefaults: Persistence) {
        self.certificateList = certificateList
        self.revocationRepository = revocationRepository
        self.vaccinationRepository = vaccinationRepository
        self.date = date
        self.userDefaults = userDefaults
    }

    public func execute() -> Promise<CertificateList> {
        guard shouldBeQueriedRevoked() else {
            return .value(certificateList)
        }
        return firstly {
            areRevoked(certificateList.certificates)
        }
        .then { tokens in
            .value(CertificateList(certificates: tokens,
                                   favoriteCertificateId: self.certificateList.favoriteCertificateId))
        }
        .then {
            self.vaccinationRepository.saveCertificateList($0)
        }
    }

    private func shouldBeQueriedRevoked() -> Bool {
        if let lastQueriedDate = userDefaults.lastQueriedRevocation,
           let lastQueriedDateAddedOneDay = Calendar.current.date(byAdding: .day, value: 1, to: lastQueriedDate),
           date < lastQueriedDateAddedOneDay {
            return false
        }
        return true
    }

    private func areRevoked(_ tokens: [ExtendedCBORWebToken]) -> Guarantee<[ExtendedCBORWebToken]> {
        let showCertificatesReissuePromises = tokens
            .map(isRevoked(_:))
        let guarantee = when(fulfilled: showCertificatesReissuePromises.makeIterator(),
                             concurrently: 1)
            .recover { _ in
                .value([])
            }
        return guarantee
    }

    private func isRevoked(_ token: ExtendedCBORWebToken) -> Promise<ExtendedCBORWebToken> {
        firstly {
            revocationRepository.isRevoked(token)
        }
        .then { isRevoked -> Promise<ExtendedCBORWebToken> in
            var tmpToken = token
            tmpToken.revoked = isRevoked
            return .value(tmpToken)
        }
        .ensure {
            self.userDefaults.lastQueriedRevocation = self.date
        }
    }
}
