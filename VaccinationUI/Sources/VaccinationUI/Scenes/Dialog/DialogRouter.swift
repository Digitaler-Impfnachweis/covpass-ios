//
//  File.swift
//
//
//  Created by Sebastian Maschinski on 07.05.21.
//

import Foundation

public struct DialogRouter: DialogRouterProtocol {
    public let sceneCoordinator: SceneCoordinator

    public init(sceneCoordinator: SceneCoordinator) {
        self.sceneCoordinator = sceneCoordinator
    }
}
