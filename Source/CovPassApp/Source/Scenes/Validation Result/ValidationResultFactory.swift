//
//  ValidationResultFactory.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import CovPassUI
import Foundation


struct ValidationResultFactory {
    static func createViewModel(router: ValidationResultRouterProtocol,
                                       repository: VaccinationRepositoryProtocol,
                                       certificate: CBORWebToken?,
                                       error: Error?,
                                       type: DCCCertLogic.LogicType = .eu,
                                       token: VAASValidaitonResultToken) -> ValidationResultViewModel {
        guard let cert = certificate, error == nil else {
            return ErrorResultViewModel(router: router, repository: repository, error: error ?? ValidationResultError.technical, token: token)
        }
        
        let validationResult = token.result

        
        switch validationResult {
        case .passed:
            if cert.hcert.dgc.r != nil {
                return RecoveryResultViewModel(router: router, repository: repository, certificate: certificate, token: token)
            }
            if cert.hcert.dgc.t != nil {
                return TestResultViewModel(router: router, repository: repository, certificate: certificate, token: token)
            }
            return VaccinationResultViewModel(router: router, repository: repository, certificate: certificate, token: token)
        case .fail:
            return ErrorResultViewModel(router: router, repository: repository, certificate: certificate, error: ValidationResultError.functional, token: token)
        case .crossCheck:
            return ErrorResultViewModel(router: router, repository: repository, certificate: certificate, error: ValidationResultError.functional, token: token)
        }
        
    }
}
