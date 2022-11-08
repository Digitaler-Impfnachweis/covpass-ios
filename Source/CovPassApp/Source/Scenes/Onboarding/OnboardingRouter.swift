//
//  OnboardingRouter.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import CovPassUI
import Foundation
import UIKit

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
        let fileSource: String? = Locale.current.isGerman() ? "privacy-covpass-de" : "privacy-covpass-en"
        let staticHtmlUrl = Bundle.main.url(forResource: fileSource, withExtension: "html")
        let factory = WebviewSceneFactory(title: "app_information_title_datenschutz".localized,
                                          url: staticHtmlUrl!,
                                          closeButtonShown: true,
                                          embedInNavigationController: true,
                                          openingAnnounce: "accessibility_app_information_datenschutz_announce".localized,
                                          closingAnnounce: "accessibility_app_information_datenschutz_closing_announce".localized)
        sceneCoordinator.present(factory)
    }
}
