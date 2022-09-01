//
//  CertificateHolderStatusModel+Factory.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import Foundation

extension CertificateHolderStatusModel {
    init?() {
        let dccCertLogic = DCCCertLogic.create()
        let vaccinationRepository = VaccinationRepository.create()

        self.init(
            dccCertLogic: dccCertLogic,
            vaccinationRepository: vaccinationRepository
        )
    }
}
