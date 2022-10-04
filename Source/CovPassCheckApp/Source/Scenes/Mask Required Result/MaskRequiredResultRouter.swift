//
//  MaskRequiredResultRouter.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassUI
import CovPassCommon

struct MaskRequiredResultRouter: MaskRequiredResultRouterProtocol, RouterProtocol {
    let sceneCoordinator: SceneCoordinator

    func rescan() {
        #warning("TODO: Finish implementation")
    }

    func scanSecondCertificate() {
        #warning("TODO: Finish implementation")
        // Probably we need the first certificate here.
    }
    
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
