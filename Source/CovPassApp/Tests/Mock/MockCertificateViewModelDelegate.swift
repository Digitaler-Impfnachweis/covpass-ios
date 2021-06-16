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
    var updateFavoriteCalled = false
    var deleteCertificateCalled = false

    func viewModelDidUpdate() {
        updateCalled = true
    }

    func viewModelDidUpdateFavorite() {
        updateFavoriteCalled = true
    }

    func viewModelDidDeleteCertificate() {
        deleteCertificateCalled = true
    }

    var receivedError: Error?
    func viewModelUpdateDidFailWithError(_ error: Error) {
        receivedError = error
    }
}
