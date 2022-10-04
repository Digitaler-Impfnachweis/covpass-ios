//
//  MaskOptionalResultRouterMock.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassCheckApp
import CovPassCommon
import XCTest

final class MaskOptionalResultRouterMock: MaskOptionalResultRouterProtocol {
    let rescanExpectation = XCTestExpectation(description: "rescanExpectation")
    let revokeExpectation = XCTestExpectation(description: "revokeExpectation")
    var receivedRevocationKeyFilename: String?

    func rescan() {
        rescanExpectation.fulfill()
    }
    
    func revoke(token: ExtendedCBORWebToken, revocationKeyFilename: String) {
        receivedRevocationKeyFilename = revocationKeyFilename
        revokeExpectation.fulfill()
    }
}