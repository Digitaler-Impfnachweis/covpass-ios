//
//  WindowDelegateMock.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import VaccinationUI

class MockViewModelDelegate: ViewModelDelegate {
    var updateCalled = false

    func viewModelDidUpdate() {
        updateCalled = true
    }

    var receivedError: Error?
    func viewModelUpdateDidFailWithError(_ error: Error) {
        receivedError = error
    }
}
