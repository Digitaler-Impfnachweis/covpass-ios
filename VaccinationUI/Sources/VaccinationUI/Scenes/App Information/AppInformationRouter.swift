//
//  AppInformationRouter.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
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
