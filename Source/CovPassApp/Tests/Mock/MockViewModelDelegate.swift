//
//  WindowDelegateMock.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassUI
import Foundation

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
