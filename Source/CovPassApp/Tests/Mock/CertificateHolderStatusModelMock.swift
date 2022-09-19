//
//  CertificateHolderStatusModelMock.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import Foundation
import PromiseKit

struct CertificateHolderStatusModelMock: CertificateHolderStatusModelProtocol {
    var needsMask = false
    var holderIsFullyImmunized = false
    
    func holderIsFullyImmunized(_ certificates: [ExtendedCBORWebToken]) -> Bool {
        holderIsFullyImmunized
    }

    func holderNeedsMask(_ certificates: [ExtendedCBORWebToken]) -> Bool {
        needsMask
    }
    
    func holderNeedsMaskAsync(_ certificates: [ExtendedCBORWebToken]) -> Guarantee<Bool> {
        .value(needsMask)
    }
}
