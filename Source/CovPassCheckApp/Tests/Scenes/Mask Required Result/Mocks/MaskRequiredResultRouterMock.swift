//
//  MaskRequiredResultRouterMock.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassCheckApp
import XCTest

final class MaskRequiredResultRouterMock: MaskRequiredResultRouterProtocol {
    let rescanExpectation = XCTestExpectation(description: "rescanExpectation")
    let scanSecondCertificateExpectation = XCTestExpectation(description: "scanSecondCertificateExpectation")

    func rescan() {
        rescanExpectation.fulfill()
    }

    func scanSecondCertificate() {
        scanSecondCertificateExpectation.fulfill()
    }
}
