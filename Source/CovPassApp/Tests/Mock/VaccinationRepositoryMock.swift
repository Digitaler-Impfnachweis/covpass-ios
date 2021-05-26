//
//  VaccinationRepositoryMock.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import Foundation
import PromiseKit

public class VaccinationRepositoryMock: VaccinationRepositoryProtocol {
    public func getLastUpdatedTrustList() -> Date? {
        return nil
    }

    public func updateTrustList() -> Promise<Void> {
        return Promise.value
    }

    public func getVaccinationCertificateList() -> Promise<VaccinationCertificateList> {
        return Promise.value(VaccinationCertificateList(certificates: []))
    }

    public func saveVaccinationCertificateList(_: VaccinationCertificateList) -> Promise<VaccinationCertificateList> {
        return Promise.value(VaccinationCertificateList(certificates: []))
    }

    public func delete(_ vaccination: Vaccination) -> Promise<Void> {
        .value
    }

    var favoriteToggle = false
    public func toggleFavoriteStateForCertificateWithIdentifier(_ id: String) -> Promise<Bool> {
        favoriteToggle.toggle()
        return .value(favoriteToggle)
    }

    public func favoriteStateForCertificates(_ certificates: [ExtendedCBORWebToken]) -> Promise<Bool> {
        .value(favoriteToggle)
    }

    public func scanVaccinationCertificate(_: String) -> Promise<ExtendedCBORWebToken> {
        return Promise { seal in
            seal.reject(ApplicationError.unknownError)
        }
    }

    public func checkVaccinationCertificate(_: String) -> Promise<CBORWebToken> {
        return Promise { seal in
            seal.reject(ApplicationError.unknownError)
        }
    }
}
