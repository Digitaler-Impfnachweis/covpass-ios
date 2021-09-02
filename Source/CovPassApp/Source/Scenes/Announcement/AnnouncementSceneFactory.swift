//
//  AnnouncementSceneFactory.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassUI
import PromiseKit
import UIKit

struct AnnouncementSceneFactory: ResolvableSceneFactory {
    // MARK: - Properties

    let router: AnnouncementRouter

    // MARK: - Lifecycle

    init(router: AnnouncementRouter) {
        self.router = router
    }

    func make(resolvable: Resolver<Void>) -> UIViewController {
        let viewModel = AnnouncementViewModel(
            router: router,
            resolvable: resolvable
        )
        return AnnouncementViewController(viewModel: viewModel)
    }
}
