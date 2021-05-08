//
//  WindowDelegateMock.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
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
