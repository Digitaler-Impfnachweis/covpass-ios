//
//  ImprintSceneFactory.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import PromiseKit
import UIKit

public struct ImprintSceneFactory: SceneFactory {
    // MARK: - Lifecycle

    public init() {}

    public func make() -> UIViewController {
        let viewModel = ImprintViewModel()
        return ImprintViewController(viewModel: viewModel)
    }
}
