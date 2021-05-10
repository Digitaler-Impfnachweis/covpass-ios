//
//  ProofRouter.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

import PromiseKit
import UIKit
import VaccinationCommon
import VaccinationUI

class HowToScanRouter: HowToScanRouterProtocol {
    // MARK: - Properties

    let sceneCoordinator: SceneCoordinator

    // MARK: - Lifecycle

    init(sceneCoordinator: SceneCoordinator) {
        self.sceneCoordinator = sceneCoordinator
    }

    // MARK: - Methods

    func showMoreInformation() {
        let webViewScene = WebviewSceneFactory(title: "Häufige Fragen".localized, url: URL(string: "https://www.digitaler-impfnachweis-app.de/webviews/client-app/faq/")!)
        sceneCoordinator.present(webViewScene)
    }
}
