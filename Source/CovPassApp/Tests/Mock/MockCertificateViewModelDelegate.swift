//
//  MockCertificateViewModelDelegate.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
@testable import CovPassApp
import VaccinationUI

class MockCertificateViewModelDelegate: CertificateViewModelDelegate {
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
