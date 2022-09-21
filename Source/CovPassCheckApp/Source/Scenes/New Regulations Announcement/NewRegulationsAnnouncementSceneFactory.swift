//
//  NewRegulationsAnnouncementSceneFactory.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassUI
import PromiseKit
import UIKit

struct NewRegulationsAnnouncementSceneFactory: ResolvableSceneFactory {
    func make(resolvable: Resolver<Void>) -> UIViewController {
        let viewModel = NewRegulationsAnnouncementViewModel(resolver: resolvable)
        let viewController = NewRegulationsAnnouncementViewController(
            viewModel: viewModel
        )

        return viewController
    }
}

