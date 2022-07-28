//
//  ResultViewModelDelegateMock.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassUI
import XCTest

class ResultViewModelDelegateMock: ResultViewModelDelegate {
    let viewModelDidUpdateExpectation = XCTestExpectation()
    func viewModelDidUpdate() {
        viewModelDidUpdateExpectation.fulfill()
    }

    func viewModelDidChange(_ newViewModel: ValidationResultViewModel) {}
}
