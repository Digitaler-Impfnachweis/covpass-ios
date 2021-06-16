//
//  AppInformationRouter.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation

public struct AppInformationRouter: AppInformationRouterProtocol {
    // MARK: - Properties

    public let sceneCoordinator: SceneCoordinator

    // MARK: - Lifecycle

    public init(sceneCoordinator: SceneCoordinator) {
        self.sceneCoordinator = sceneCoordinator
    }

    // MARK: - Methods

    public func showScene(_ scene: SceneFactory) {
        sceneCoordinator.push(scene)
    }
}
