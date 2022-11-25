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
        let title = "app_information_title_faq".localized
        let germanUrl = "https://www.digitaler-impfnachweis-app.de/webviews/client-app/faq/"
        let englishUrl = "https://www.digitaler-impfnachweis-app.de/en/webviews/client-app/faq/"
        let url = URL(string: Locale.current.isGerman() ? germanUrl : englishUrl)!
        let faqTitleOpen = "accessibility_app_information_title_faq_announce".localized
        let faqTitleClose = "accessibility_app_information_title_faq_announce_closing".localized
        let factory = WebviewSceneFactory(title: title,
                                          url: url,
                                          closeButtonShown: true,
                                          embedInNavigationController: true,
                                          openingAnnounce: faqTitleOpen,
                                          closingAnnounce: faqTitleClose)
        sceneCoordinator.present(factory)
    }
}
