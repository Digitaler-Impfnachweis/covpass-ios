//
import CovPassCommon
//  RevocationRepositoryMocks.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//
import Foundation
import PromiseKit
import XCTest

class CertificateRevocationRepositoryMock: CertificateRevocationRepositoryProtocol {
    let isRevokedExpectation = XCTestExpectation()
    var isRevoked = false
    func isRevoked(_: ExtendedCBORWebToken) -> Guarantee<Bool> {
        isRevokedExpectation.fulfill()
        return .value(isRevoked)
    }
}
