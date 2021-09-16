//
//  BoosterNotificationSceneFactory.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import CovPassUI
import PromiseKit
import UIKit

struct BoosterNotificationSceneFactory: ResolvableSceneFactory {
    // MARK: - Lifecycle

    func make(resolvable: Resolver<Void>) -> UIViewController {
        let viewModel = BoosterNotificationViewModel(resolvable: resolvable)
        return BoosterNotificationViewController(viewModel: viewModel)
    }
}
