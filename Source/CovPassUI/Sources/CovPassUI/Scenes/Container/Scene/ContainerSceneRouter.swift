//
//  ContainerSceneRouter.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation

public struct ContainerSceneRouter: ContainerSceneRouterProtocol {
    public let sceneCoordinator: SceneCoordinator

    public init(sceneCoordinator: SceneCoordinator) {
        self.sceneCoordinator = sceneCoordinator
    }

    public func dismiss() {
        sceneCoordinator.dismiss()
    }
}
