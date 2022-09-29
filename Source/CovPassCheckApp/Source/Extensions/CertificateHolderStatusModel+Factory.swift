//
//  CertificateHolderStatusModel+Factory.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import Foundation

extension CertificateHolderStatusModel {
    static func create() -> CertificateHolderStatusModel {
        let dccCertLogic = DCCCertLogic.create()
        return .init(dccCertLogic: dccCertLogic)
    }
}
