//
//  MaskRequiredResultRouterMock.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassCheckApp
import CovPassCommon
import XCTest

final class MaskRequiredResultRouterMock: MaskRequiredResultRouterProtocol {
    
    let rescanExpectation = XCTestExpectation(description: "rescanExpectation")
    let revokeExpectation = XCTestExpectation(description: "revokeExpectation")
    var receivedRevocationKeyFilename: String?
    let scanSecondCertificateExpectation = XCTestExpectation(description: "scanSecondCertificateExpectation")
    
    func rescan() {
        rescanExpectation.fulfill()
    }
    
    func scanSecondCertificate() {
        scanSecondCertificateExpectation.fulfill()
    }
    
    func revoke(token: ExtendedCBORWebToken, revocationKeyFilename: String) {
        receivedRevocationKeyFilename = revocationKeyFilename
        revokeExpectation.fulfill()
    }
}
