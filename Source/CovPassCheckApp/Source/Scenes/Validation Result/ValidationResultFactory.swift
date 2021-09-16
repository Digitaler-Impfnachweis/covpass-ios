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
    static func createViewModel(router: ValidationResultRouterProtocol, repository: VaccinationRepositoryProtocol, certificate: CBORWebToken?, certLogic: DCCCertLogic = DCCCertLogic.create()) -> ValidationResultViewModel {
        guard let cert = certificate else {
            return ErrorResultViewModel(router: router, repository: repository)
        }

        do {
            // Validate given certificate based on GERMAN rules and users local time (CovPassCheck only)
            let validationResult = try certLogic.validate(countryCode: "DE", validationClock: Date(), certificate: cert)
            let valid = validationResult.contains(where: { $0.result != .passed }) == false

            // Show error dialog when at least one rule failed or there are no rules at all
            if !valid || validationResult.isEmpty {
                return ErrorResultViewModel(router: router, repository: repository, certificate: certificate)
            }
            if certificate?.hcert.dgc.r?.isEmpty == false {
                return RecoveryResultViewModel(router: router, repository: repository, certificate: certificate)
            }
            if certificate?.hcert.dgc.t?.isEmpty == false {
                return TestResultViewModel(router: router, repository: repository, certificate: certificate)
            }
            return VaccinationResultViewModel(router: router, repository: repository, certificate: certificate)
        } catch {
            return ErrorResultViewModel(router: router, repository: repository, certificate: certificate)
        }
    }
}
