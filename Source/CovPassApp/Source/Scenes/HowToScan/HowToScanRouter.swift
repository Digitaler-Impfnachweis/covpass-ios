//
//  ProofRouter.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import CovPassUI
import PromiseKit
import UIKit

class HowToScanRouter: HowToScanRouterProtocol {
    // MARK: - Properties

    let sceneCoordinator: SceneCoordinator

    // MARK: - Lifecycle

    init(sceneCoordinator: SceneCoordinator) {
        self.sceneCoordinator = sceneCoordinator
    }

    // MARK: - Methods

    func showMoreInformation() {
        let webViewScene = WebviewSceneFactory(title: "app_information_title_faq".localized, url: URL(string: Locale.current.isGerman() ? "https://www.digitaler-impfnachweis-app.de/webviews/client-app/faq/" : "https://www.digitaler-impfnachweis-app.de/en/webviews/client-app/faq/")!, closeButtonShown: true, embedInNavigationController: true)
        sceneCoordinator.present(webViewScene)
    }
}
