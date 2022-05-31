//
//  MockCertificateViewModelDelegate.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassApp
import CovPassUI
import Foundation
import XCTest

class MockCertificateViewModelDelegate: CertificatesOverviewViewModelDelegate {
    var updateCalled = false
    var needsFirstCertificateVisibleCalled = false
    var needsCertificateVisibleAtIndex: Int?
    let viewModelDidUpdateExpectation = XCTestExpectation(description: "viewModelDidUpdateExpectation")

    func viewModelDidUpdate() {
        updateCalled = true
        viewModelDidUpdateExpectation.fulfill()
    }

    func viewModelNeedsFirstCertificateVisible() {
        needsFirstCertificateVisibleCalled = true
    }

    func viewModelNeedsCertificateVisible(at index: Int) {
        needsCertificateVisibleAtIndex = index
    }
}
