//
//  RuleCheckDetailRouterMock.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassApp
import CovPassCommon
import CovPassUI
import PromiseKit

struct RuleCheckDetailRouterMock: RuleCheckDetailRouterProtocol {
    var sceneCoordinator: SceneCoordinator

    init() {
        sceneCoordinator = SceneCoordinatorMock()
    }

    func showCertificate(for token: ExtendedCBORWebToken) -> Promise<Void> {
        .value
    }
}
