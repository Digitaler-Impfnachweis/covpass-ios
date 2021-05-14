//
//  VaccinationRepositoryMock.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import PromiseKit
import VaccinationCommon

public struct VaccinationRepositoryMock: VaccinationRepositoryProtocol {
    public func getVaccinationCertificateList() -> Promise<VaccinationCertificateList> {
        return Promise.value(VaccinationCertificateList(certificates: []))
    }

    public func saveVaccinationCertificateList(_: VaccinationCertificateList) -> Promise<VaccinationCertificateList> {
        return Promise.value(VaccinationCertificateList(certificates: []))
    }

    public func refreshValidationCA() -> Promise<Void> {
        return Promise.value(())
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
