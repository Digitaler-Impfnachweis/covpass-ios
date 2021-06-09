//
//  ValidationResultFactory.swift
//  CovPassCheckApp
//
//  Created by Timo Koenig on 06.06.21.
//  Copyright © 2021 IBM. All rights reserved.
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
