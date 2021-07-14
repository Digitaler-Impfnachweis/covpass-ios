//
//  DateSelectionSceneFactory.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassUI
import PromiseKit
import UIKit

struct DateSelectionSceneFactory: ResolvableSceneFactory {
    // MARK: - Properties

    let router: DateSelectionRouterProtocol
    let date: Date

    // MARK: - Lifecycle

    init(router: DateSelectionRouterProtocol, date: Date) {
        self.router = router
        self.date = date
    }

    func make(resolvable: Resolver<Date>) -> UIViewController {
        let viewModel = DateSelectionViewModel(
            router: router,
            resolvable: resolvable,
            date: date
        )
        return DateSelectionViewController(viewModel: viewModel)
    }
}
