//
//  ValidationResultFactory.swift
// 
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import Foundation

struct ValidationResultFactory {
    static func createViewModel(router: ValidationResultRouterProtocol, repository: VaccinationRepositoryProtocol, certificate: CBORWebToken?) -> ValidationResultViewModel {
        if certificate?.hcert.dgc.r != nil {
            return RecoveryResultViewModel(router: router, repository: repository, certificate: certificate)
        }
        if certificate?.hcert.dgc.t != nil {
            return TestResultViewModel(router: router, repository: repository, certificate: certificate)
        }
        return VaccinationResultViewModel(router: router, repository: repository, certificate: certificate)
    }
}
