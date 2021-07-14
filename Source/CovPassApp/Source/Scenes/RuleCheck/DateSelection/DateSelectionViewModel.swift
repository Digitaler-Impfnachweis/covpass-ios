//
//  DateSelectionViewModel.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassUI
import LocalAuthentication
import PromiseKit
import UIKit

enum DateStep {
    case One
    case Two
}

class DateSelectionViewModel: BaseViewModel, CancellableViewModelProtocol {
    // MARK: - Properties

    weak var delegate: ViewModelDelegate?
    let router: DateSelectionRouterProtocol
    let resolver: Resolver<Date>
    var date: Date
    var step: DateStep = .One

    // MARK: - Lifecycle

    init(
        router: DateSelectionRouterProtocol,
        resolvable: Resolver<Date>,
        date: Date
    ) {
        self.router = router
        resolver = resolvable
        self.date = date
    }

    func done() {
        if step == .One {
            step = .Two
            delegate?.viewModelDidUpdate()
        } else {
            resolver.fulfill(date)
        }
    }

    func cancel() {
        resolver.cancel()
    }

    func back() {
        step = .One
        delegate?.viewModelDidUpdate()
    }
}
