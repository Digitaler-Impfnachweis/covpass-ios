//
//  DataPrivacySceneFactory.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassUI
import PromiseKit
import UIKit

public struct DataPrivacySceneFactory: ResolvableSceneFactory {
    // MARK: - Properties

    private let router: DataPrivacyRouter

    // MARK: - Lifecycle

    public init(router: DataPrivacyRouter) {
        self.router = router
    }

    public func make(resolvable: Resolver<Void>) -> UIViewController {
        let filename = Locale.current.isGerman() ? "privacy-covpasscheck-de" : "privacy-covpasscheck-en"
        guard let url = Bundle.main.url(
            forResource: filename,
            withExtension: "html"
        ) else {
            fatalError("Must not fail.")
        }
        let viewModel = DataPrivacyViewModel(
            router: router,
            resolvable: resolvable,
            privacyURL: url
        )
        return DataPrivacyViewController(viewModel: viewModel)
    }
}

