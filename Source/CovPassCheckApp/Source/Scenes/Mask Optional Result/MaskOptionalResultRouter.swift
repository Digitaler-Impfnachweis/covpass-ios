//
//  MaskOptionalResultRouter.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import CovPassUI

struct MaskOptionalResultRouter: MaskOptionalResultRouterProtocol, RouterProtocol {
    let sceneCoordinator: SceneCoordinator

    func revoke(token: ExtendedCBORWebToken, revocationKeyFilename: String) {
        sceneCoordinator.present(
            RevocationInfoSceneFactory(
                keyFilename: revocationKeyFilename,
                router: RevocationInfoRouter(sceneCoordinator: sceneCoordinator),
                token: token
            )
        ).cauterize()
    }
}
