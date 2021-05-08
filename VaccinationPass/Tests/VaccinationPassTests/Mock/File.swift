//
//  MockCertificateViewModelDelegate.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

@testable import VaccinationPass
import Foundation
import VaccinationUI
import VaccinationPass

class MockCertificateViewModelDelegate: CertificateViewModelDelegate {
    var updateCalled = false
    var updateFavoriteCalled = false

    func viewModelDidUpdate() {
        updateCalled = true
    }

    func viewModelDidUpdateFavorite() {
        updateFavoriteCalled = true
    }

    var receivedError: Error?
    func viewModelUpdateDidFailWithError(_ error: Error) {
        receivedError = error
    }
}
