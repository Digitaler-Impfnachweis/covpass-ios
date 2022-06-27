//
//  CertificateImportSelectionRouterMock.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassApp
import PromiseKit
import XCTest

struct CertificateImportSelectionRouterMock: CertificateImportSelectionRouterProtocol {
    let showTooManyHoldersErrorExpectation = XCTestExpectation(description: "showTooManyHoldersErrorExpectation")
    let showImportSuccessExpectation = XCTestExpectation(description: "showImportSuccessExpectation")

    func showTooManyHoldersError() {
        showTooManyHoldersErrorExpectation.fulfill()
    }

    func showImportSuccess() -> Promise<Void> {
        showImportSuccessExpectation.fulfill()
        return .value
    }
}
