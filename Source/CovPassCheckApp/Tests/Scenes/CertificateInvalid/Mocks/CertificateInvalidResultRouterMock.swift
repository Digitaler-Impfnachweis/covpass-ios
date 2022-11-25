//
//  CertificateInvalidResultRouterMock.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassCheckApp
import CovPassCommon
import XCTest

final class CertificateInvalidResultRouterMock: CertificateInvalidResultRouterProtocol {
    let revokeExpectation = XCTestExpectation(description: "revokeExpectation")
    var receivedRevocationKeyFilename: String?

    func revoke(token _: ExtendedCBORWebToken, revocationKeyFilename: String) {
        receivedRevocationKeyFilename = revocationKeyFilename
        revokeExpectation.fulfill()
    }
}
