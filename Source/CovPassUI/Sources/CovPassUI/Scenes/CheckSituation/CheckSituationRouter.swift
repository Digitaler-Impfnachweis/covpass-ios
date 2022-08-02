//
//  CheckSituationRouter.swift
//  
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

public struct CheckSituationRouter: CheckSituationRouterProtocol, DialogRouterProtocol {
    public var sceneCoordinator: SceneCoordinator
    
    public init(sceneCoordinator: SceneCoordinator) {
        self.sceneCoordinator = sceneCoordinator
    }
}
