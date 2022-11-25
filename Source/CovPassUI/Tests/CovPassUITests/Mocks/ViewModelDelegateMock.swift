//
//  ViewModelDelegateMock.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassUI

class ViewModelDelegateMock: ViewModelDelegate {
    var didUpdate: (() -> Void)?
    var didFail: ((Error) -> Void)?

    func viewModelDidUpdate() {
        didUpdate?()
    }

    func viewModelUpdateDidFailWithError(_ error: Error) {
        didFail?(error)
    }
}
