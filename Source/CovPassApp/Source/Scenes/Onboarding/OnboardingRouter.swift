//
//  OnboardingRouter.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import UIKit
import CovPassCommon
import CovPassUI

struct OnboardingRouter: OnboardingRouterProtocol {
    // MARK: - Properties

    let sceneCoordinator: SceneCoordinator

    // MARK: - Lifecycle

    init(sceneCoordinator: SceneCoordinator) {
        self.sceneCoordinator = sceneCoordinator
    }

    // MARK: - Methods

    func showNextScene() {
        sceneCoordinator.asRoot(
            CertificatesOverviewSceneFactory(
                router: CertificatesOverviewRouter(sceneCoordinator: sceneCoordinator)
            )
        )
    }

    func showPreviousScene() {
        sceneCoordinator.asRoot(
            WelcomeSceneFactory(
                router: WelcomeRouter(sceneCoordinator: sceneCoordinator)
            )
        )
    }

    func showDataPrivacyScene() {
        let staticHtmlUrl = Bundle.main.url(forResource: "privacy-covpass", withExtension: "html")
        let webViewScene = WebviewSceneFactory(title: "app_information_title_datenschutz_linked".localized, url: staticHtmlUrl!, closeButtonShown: true)
        sceneCoordinator.present(webViewScene)
    }
}
