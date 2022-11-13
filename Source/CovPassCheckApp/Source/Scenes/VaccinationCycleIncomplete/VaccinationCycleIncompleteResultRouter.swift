//
//  VaccinationCycleIncompleteResultRouter.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import CovPassUI
import UIKit

struct VaccinationCycleIncompleteResultRouter: VaccinationCycleIncompleteResultRouterProtocol {
    let sceneCoordinator: SceneCoordinator

    func openFAQ(_ url: URL) {
        UIApplication.shared.open(url)
    }
}
