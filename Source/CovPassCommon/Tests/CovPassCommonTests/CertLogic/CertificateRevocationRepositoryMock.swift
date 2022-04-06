//
 //  RevocationRepositoryMocks.swift
 //
 //  © Copyright IBM Deutschland GmbH 2021
 //  SPDX-License-Identifier: Apache-2.0
 //
 import Foundation
 import CovPassCommon
 import PromiseKit
import XCTest

 class CertificateRevocationRepositoryMock: CertificateRevocationRepositoryProtocol {
     let isRevokedExpectation = XCTestExpectation()
     var isRevoked = false
     func isRevoked(_ webToken: ExtendedCBORWebToken) -> Guarantee<Bool> {
         return .value(isRevoked)
     }
 }
