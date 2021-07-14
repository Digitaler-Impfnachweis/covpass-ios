//
// RuleCheckDetailSceneFactory.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassUI
import PromiseKit
import UIKit

struct RuleCheckDetailSceneFactory: ResolvableSceneFactory {
    // MARK: - Properties

    let router: RuleCheckDetailRouterProtocol
    let result: CertificateResult
    let country: String
    let date: Date

    // MARK: - Lifecycle

    init(router: RuleCheckDetailRouterProtocol, result: CertificateResult, country: String, date: Date) {
        self.router = router
        self.result = result
        self.country = country
        self.date = date
    }

    func make(resolvable: Resolver<Void>) -> UIViewController {
        let viewModel = RuleCheckDetailViewModel(
            router: router,
            resolvable: resolvable,
            result: result,
            country: country,
            date: date
        )
        return RuleCheckDetailViewController(viewModel: viewModel)
    }
}
