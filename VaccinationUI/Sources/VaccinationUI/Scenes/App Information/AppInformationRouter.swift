//
//  File.swift
//  
//
//  Created by Sebastian Maschinski on 06.05.21.
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
