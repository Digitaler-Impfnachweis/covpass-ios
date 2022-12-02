//
//  SelectStateOnboardingViewRouter.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import PromiseKit

private enum Constants {
    public static let faqTitle = "app_information_title_faq".localized(bundle: .main)
    public static let faqAnnouncementOpen = "accessibility_app_information_title_faq_announce".localized(bundle: .main)
    public static let faqAnnouncementClose = "accessibility_app_information_title_faq_announce_closing".localized(bundle: .main)
}

public struct SelectStateOnboardingViewRouter: SelectStateOnboardingViewRouterProtocol {
    // MARK: - Properties

    public let sceneCoordinator: SceneCoordinator

    // MARK: - Lifecycle

    public init(sceneCoordinator: SceneCoordinator) {
        self.sceneCoordinator = sceneCoordinator
    }

    // MARK: - Methods

    public func showFederalStateSelection() -> Promise<Void> {
        sceneCoordinator.present(StateSelectionSceneFactory(), animated: true)
    }

    public func showFAQ() {
        sceneCoordinator.present(
            ContainerSceneFactory(
                title: Constants.faqTitle,
                embeddedViewController: WebviewSceneFactory(
                    title: Constants.faqTitle,
                    url: URL(string: "https://www.digitaler-impfnachweis-app.de/en/webviews/client-app/faq/")!,
                    openingAnnounce: Constants.faqAnnouncementOpen,
                    closingAnnounce: Constants.faqAnnouncementClose
                ),
                sceneCoordinator: sceneCoordinator
            )
        )
    }
}
