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
                                type: DCCCertLogic.LogicType,
                                certLogic: DCCCertLogicProtocol,
                                _2GContext: Bool,
                                userDefaults: Persistence) -> ValidationResultViewModel {
        guard let cert = certificate, error == nil else {
            return ErrorResultViewModel(resolvable: resolvable,
                                        router: router,
                                        repository: repository,
                                        error: error ?? ValidationResultError.technical,
                                        _2GContext: _2GContext,
                                        userDefaults: userDefaults)
        }
        
        do {
            // Validate given certificate based on GERMAN rules and users local time (CovPassCheck only)
            let validationResult = try certLogic.validate(type: type, countryCode: "DE", validationClock: Date(), certificate: cert.vaccinationCertificate)
            let valid = validationResult.contains(where: { $0.result != .passed }) == false
            
            // Show error dialog when at least one rule failed or there are no rules at all
            if !valid {
                return ErrorResultViewModel(resolvable: resolvable,
                                            router: router,
                                            repository: repository,
                                            certificate: cert,
                                            error: ValidationResultError.functional,
                                            _2GContext: _2GContext,
                                            userDefaults: userDefaults)
            }
            if validationResult.isEmpty {
                return ErrorResultViewModel(resolvable: resolvable,
                                            router: router,
                                            repository: repository,
                                            certificate: cert,
                                            error: ValidationResultError.technical,
                                            _2GContext: _2GContext,
                                            userDefaults: userDefaults)
            }
            if cert.vaccinationCertificate.hcert.dgc.r?.isEmpty == false {
                return RecoveryResultViewModel(resolvable: resolvable,
                                               router: router,
                                               repository: repository,
                                               certificate: cert,
                                               _2GContext: _2GContext,
                                               userDefaults: userDefaults)
            }
            if cert.vaccinationCertificate.hcert.dgc.t?.isEmpty == false {
                return TestResultViewModel(resolvable: resolvable,
                                           router: router,
                                           repository: repository,
                                           certificate: cert,
                                           _2GContext: _2GContext,
                                           userDefaults: userDefaults)
            }
            return VaccinationResultViewModel(resolvable: resolvable,
                                              router: router,
                                              repository: repository,
                                              certificate: cert,
                                              _2GContext: _2GContext,
                                              userDefaults: userDefaults)
        } catch {
            return ErrorResultViewModel(resolvable: resolvable,
                                        router: router,
                                        repository: repository,
                                        certificate: cert,
                                        error: ValidationResultError.technical,
                                        _2GContext: _2GContext,
                                        userDefaults: userDefaults)
        }
    }
}
