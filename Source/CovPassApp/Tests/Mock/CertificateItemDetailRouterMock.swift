//
//  CertificateItemDetailRouterMock.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassApp
import CovPassCommon
import CovPassUI
import PromiseKit

struct CertificateItemDetailRouterMock: CertificateItemDetailRouterProtocol {
    func showReissue(for _: [ExtendedCBORWebToken], context _: ReissueContext) -> Promise<Void> {
        .value
    }

    var sceneCoordinator: SceneCoordinator = SceneCoordinatorMock()

    func showCertificate(for _: ExtendedCBORWebToken) -> Promise<Void> {
        .value(())
    }

    func showPDFExport(for _: ExtendedCBORWebToken) -> Promise<Void> {
        .value(())
    }
}
