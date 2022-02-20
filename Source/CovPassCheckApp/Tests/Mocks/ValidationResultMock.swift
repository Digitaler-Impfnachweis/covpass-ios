//
//  ValidationResultMock.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassUI
import PromiseKit

struct ValidationResultRouterMock: ValidationResultRouterProtocol {

    func showStart() {}

    func scanQRCode() -> Promise<ScanResult> {
        .value(.success(""))
    }

    var sceneCoordinator: SceneCoordinator = SceneCoordinatorMock()
}
