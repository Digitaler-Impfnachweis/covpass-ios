//
//  ScanPleaseRouter.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassUI
import Foundation
import UIKit

private enum Constants {
    static let checkAppUrl = URL(string: "https://apps.apple.com/de/app/covpass-check/id1566140314")!
}

public protocol ScanPleaseRoutable: RouterProtocol {
    func routeToCheckApp()
}

class ScanPleaseRouter: ScanPleaseRoutable {
    // MARK: - Properties

    let sceneCoordinator: SceneCoordinator

    // MARK: - Lifecycle

    init(sceneCoordinator: SceneCoordinator) {
        self.sceneCoordinator = sceneCoordinator
    }

    func routeToCheckApp() {
        if UIApplication.shared.canOpenURL(Constants.checkAppUrl) {
            UIApplication.shared.open(Constants.checkAppUrl)
        }
    }
}
