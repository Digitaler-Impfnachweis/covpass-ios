//
//  CertificateHolderStatusModelMock.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import Foundation

struct CertificateHolderStatusModelMock: CertificateHolderStatusModelProtocol {
    var needsMask = false
    var fullyImmunized = false

    func holderNeedsMask(_ holder: Name, dateOfBirth: Date?) -> Bool {
        needsMask
    }

    func holderIsFullyImmunized(_ holder: Name, dateOfBirth: Date?) -> Bool {
        fullyImmunized
    }
}
