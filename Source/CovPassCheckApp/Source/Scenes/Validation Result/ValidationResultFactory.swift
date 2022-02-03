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
                                certLogic: DCCCertLogicProtocol,
                                _2GContext: Bool) -> ValidationResultViewModel {
        guard let cert = certificate, error == nil else {
            return ErrorResultViewModel(router: router, repository: repository, error: error ?? ValidationResultError.technical, _2GContext: _2GContext)
        }
        
        do {
            // Validate given certificate based on GERMAN rules and users local time (CovPassCheck only)
            let validationResult = try certLogic.validate(type: type, countryCode: "DE", validationClock: Date(), certificate: cert)
            let valid = validationResult.contains(where: { $0.result != .passed }) == false
            
            // Show error dialog when at least one rule failed or there are no rules at all
            if !valid {
                return ErrorResultViewModel(router: router, repository: repository, certificate: certificate, error: ValidationResultError.functional, _2GContext: _2GContext)
            }
            if validationResult.isEmpty {
                return ErrorResultViewModel(router: router, repository: repository, certificate: certificate, error: ValidationResultError.technical, _2GContext: _2GContext)
            }
            if certificate?.hcert.dgc.r?.isEmpty == false {
                return RecoveryResultViewModel(router: router, repository: repository, certificate: certificate, _2GContext: _2GContext)
            }
            if certificate?.hcert.dgc.t?.isEmpty == false {
                return TestResultViewModel(router: router, repository: repository, certificate: certificate, _2GContext: _2GContext)
            }
            return VaccinationResultViewModel(router: router, repository: repository, certificate: certificate, _2GContext: _2GContext)
        } catch {
            return ErrorResultViewModel(router: router, repository: repository, certificate: certificate, error: ValidationResultError.technical, _2GContext: _2GContext)
        }
    }
}
