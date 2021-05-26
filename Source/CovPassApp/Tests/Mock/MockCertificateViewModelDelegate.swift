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

class MockCertificateViewModelDelegate: CertificatesOverviewViewModelDelegate {
    var updateCalled = false
    var needsFirstCertificateVisibleCalled = false
    var needsCertificateVisibleAtIndex: Int?

    func viewModelDidUpdate() {
        updateCalled = true
    }

    func viewModelNeedsFirstCertificateVisible() {
        needsFirstCertificateVisibleCalled = true
    }

    func viewModelNeedsCertificateVisible(at index: Int) {
        needsCertificateVisibleAtIndex = index
    }
}
