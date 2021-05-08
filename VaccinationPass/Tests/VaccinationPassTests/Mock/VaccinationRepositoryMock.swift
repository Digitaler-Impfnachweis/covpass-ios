//
//  VaccinationRepositoryMock.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
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

    public func reissueValidationCertificate(_: ExtendedCBORWebToken) -> Promise<ExtendedCBORWebToken> {
        return Promise { seal in
            seal.reject(ApplicationError.unknownError)
        }
    }

    public func checkValidationCertificate(_: String) -> Promise<CBORWebToken> {
        return Promise { seal in
            seal.reject(ApplicationError.unknownError)
        }
    }
}
