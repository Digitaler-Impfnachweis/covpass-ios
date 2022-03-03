//
//  CertificateItemDetailRouterMock.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import PromiseKit
import CovPassUI
@testable import CovPassApp

struct CertificateItemDetailRouterMock: CertificateItemDetailRouterProtocol {
    
    var sceneCoordinator: SceneCoordinator = SceneCoordinatorMock()

    func showCertificate(for token: ExtendedCBORWebToken) -> Promise<Void> {
        .value(())
    }
    
    func showPDFExport(for token: ExtendedCBORWebToken) -> Promise<Void> {
        .value(())
    }
}
