//
//  SundownInfoSceneFactory.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import PromiseKit
import UIKit

public struct SundownInfoSceneFactory: ResolvableSceneFactory {
    // MARK: - Properties

    // MARK: - Lifecycle

    public init() {}

    public func make(resolvable: Resolver<Void>) -> UIViewController {
        let persistence = UserDefaultsPersistence()
        let viewModel = SundownInfoViewModel(
            resolvable: resolvable,
            persistence: persistence
        )
        return SundownInfoViewController(viewModel: viewModel)
    }
}
