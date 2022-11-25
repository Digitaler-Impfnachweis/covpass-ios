//
//  StateSelectionSceneFactory.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import PromiseKit
import UIKit

public struct StateSelectionSceneFactory: ResolvableSceneFactory {
    // MARK: - Lifecycle

    public init() {}

    public func make(resolvable: Resolver<Void>) -> UIViewController {
        let persistence = UserDefaultsPersistence()
        let viewModel = StateSelectionViewModel(persistence: persistence,
                                                resolver: resolvable)
        return StateSelectionViewController(viewModel: viewModel)
    }
}
