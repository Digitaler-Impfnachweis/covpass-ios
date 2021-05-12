//
//  DialogRouter.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

import Foundation

public struct DialogRouter: DialogRouterProtocol {
    public let sceneCoordinator: SceneCoordinator

    public init(sceneCoordinator: SceneCoordinator) {
        self.sceneCoordinator = sceneCoordinator
    }
}
