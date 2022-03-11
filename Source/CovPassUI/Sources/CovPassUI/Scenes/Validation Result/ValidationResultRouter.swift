//
//  ScanResultRouter.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import Foundation
import PromiseKit
import Scanner

public struct ValidationResultRouter: ValidationResultRouterProtocol {
    
    // MARK: - Properties
    
    public let sceneCoordinator: SceneCoordinator
    
    // MARK: - Lifecycle
    
    public init(sceneCoordinator: SceneCoordinator) {
        self.sceneCoordinator = sceneCoordinator
    }
    
    // MARK: - Methods
    
    public func showStart() {
        sceneCoordinator.dimiss()
    }
    
    public func scanQRCode() -> Promise<ScanResult> {
        sceneCoordinator.present(
            ScanSceneFactory(
                cameraAccessProvider: CameraAccessProvider(
                    router: DialogRouter(sceneCoordinator: sceneCoordinator)
                )
            )
        )
    }
    
    public func showRevocation(token: ExtendedCBORWebToken) -> Promise<Void> {
        sceneCoordinator.present(
            RevocationInfoSceneFactory(
                router: RevocationInfoRouter(sceneCoordinator: sceneCoordinator),
                token: token
            )
        )
    }
}
