//
//  WindowDelegateMock.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassUI
import Foundation
import XCTest

class MockViewModelDelegate: ViewModelDelegate {
    let viewModelDidUpdateExpectation = XCTestExpectation(description: "viewModelDidUpdateExpectation")
    var updateCalled = false

    func viewModelDidUpdate() {
        updateCalled = true
        viewModelDidUpdateExpectation.fulfill()
    }

    var receivedError: Error?
    func viewModelUpdateDidFailWithError(_ error: Error) {
        receivedError = error
    }
}
