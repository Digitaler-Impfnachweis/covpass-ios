//
//  AnnouncementSceneFactory.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import PromiseKit
import UIKit

public struct DataPrivacySceneFactory: ResolvableSceneFactory {
    // MARK: - Properties

    let router: DataPrivacyRouter

    // MARK: - Lifecycle

    public init(router: DataPrivacyRouter) {
        self.router = router
    }

    public func make(resolvable: Resolver<Void>) -> UIViewController {
        let viewModel = DataPrivacyViewModel(
            router: router,
            resolvable: resolvable
        )
        return DataPrivacyViewController(viewModel: viewModel)
    }
}
