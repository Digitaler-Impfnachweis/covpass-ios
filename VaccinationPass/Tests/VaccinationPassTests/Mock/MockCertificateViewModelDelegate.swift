//
//  MockCertificateViewModelDelegate.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

import Foundation
@testable import VaccinationPass
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
