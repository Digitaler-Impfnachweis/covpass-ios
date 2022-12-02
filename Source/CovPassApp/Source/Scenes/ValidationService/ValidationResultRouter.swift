//
//  ScanResultRouter.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import CovPassUI
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
        sceneCoordinator.dismiss()
    }

    public func scanQRCode() -> Promise<QRCodeImportResult> {
        sceneCoordinator.present(
            ScanSceneFactory(
                cameraAccessProvider: CameraAccessProvider(router: DialogRouter(sceneCoordinator: sceneCoordinator)),
                router: ScanRouter(sceneCoordinator: sceneCoordinator),
                isDocumentPickerEnabled: false
            )
        )
    }

    public func showRevocation(token: ExtendedCBORWebToken, keyFilename: String) -> Promise<Void> {
        sceneCoordinator.present(
            RevocationInfoSceneFactory(
                keyFilename: keyFilename,
                router: RevocationInfoRouter(sceneCoordinator: sceneCoordinator),
                token: token
            )
        )
    }
}
