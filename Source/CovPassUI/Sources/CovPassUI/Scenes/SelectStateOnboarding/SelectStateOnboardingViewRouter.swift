//
//  SelectStateOnboardingViewRouter.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import PromiseKit

public struct SelectStateOnboardingViewRouter: SelectStateOnboardingViewRouterProtocol {
    // MARK: - Properties

    public let sceneCoordinator: SceneCoordinator

    // MARK: - Lifecycle

    public init(sceneCoordinator: SceneCoordinator) {
        self.sceneCoordinator = sceneCoordinator
    }

    // MARK: - Methods

    public func showFederalStateSelection() -> Promise<Void> {
        sceneCoordinator.present(StateSelectionSceneFactory(), animated: true)
    }
}
