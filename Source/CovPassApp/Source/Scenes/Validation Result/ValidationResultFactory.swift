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
import PromiseKit

struct ValidationResultFactory {
    static func createViewModel(resolvable: Resolver<ExtendedCBORWebToken>,
                                router: ValidationResultRouterProtocol,
                                repository: VaccinationRepositoryProtocol,
                                certificate: ExtendedCBORWebToken?,
                                error: Error?,
                                type: DCCCertLogic.LogicType = .eu,
                                token: VAASValidaitonResultToken,
                                userDefaults: Persistence) -> ValidationResultViewModel {
        guard let cert = certificate?.vaccinationCertificate, error == nil else {
            return ErrorResultViewModel(resolvable: resolvable,
                                        router: router,
                                        repository: repository,
                                        error: error ?? ValidationResultError.technical,
                                        token: token,
                                        userDefaults: userDefaults)
        }
        
        let validationResult = token.result
        
        
        switch validationResult {
        case .passed:
            if cert.hcert.dgc.r != nil {
                return RecoveryResultViewModel(resolvable: resolvable,
                                               router: router,
                                               repository: repository,
                                               certificate: certificate,
                                               token: token,
                                               userDefaults: userDefaults)
            }
            if cert.hcert.dgc.t != nil {
                return TestResultViewModel(resolvable: resolvable,
                                           router: router,
                                           repository: repository,
                                           certificate: certificate,
                                           token: token,
                                           userDefaults: userDefaults)
            }
            return VaccinationResultViewModel(resolvable: resolvable,
                                              router: router,
                                              repository: repository,
                                              certificate: certificate,
                                              token: token,
                                              userDefaults: userDefaults)
        case .fail:
            return ErrorResultViewModel(resolvable: resolvable,
                                        router: router,
                                        repository: repository,
                                        certificate: certificate,
                                        error: ValidationResultError.functional,
                                        token: token,
                                        userDefaults: userDefaults)
        case .crossCheck:
            return ErrorResultViewModel(resolvable: resolvable,
                                        router: router,
                                        repository: repository,
                                        certificate: certificate,
                                        error: ValidationResultError.functional,
                                        token: token,
                                        userDefaults: userDefaults)
        }
        
    }
}
