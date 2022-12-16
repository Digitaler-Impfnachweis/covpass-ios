//
//  WhatsNewSettingsSceneFactory.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import Foundation
import UIKit

public struct WhatsNewSettingsSceneFactory: SceneFactory {
    private let router: WhatsNewSettingsRouterProtocol

    public init(router: WhatsNewSettingsRouterProtocol) {
        self.router = router
    }

    public func make() -> UIViewController {
        let bundle = Bundle.main
        guard let url = Locale.current.isGerman() ? bundle.germanAnnouncementsURL : bundle.englishAnnouncementsURL
        else {
            fatalError("Invalid resource URL.")
        }
        let persistence = UserDefaultsPersistence()
        let viewModel = WhatsNewSettingsViewModel(
            persistence: persistence,
            whatsNewURL: url
        )
        let viewController = WhatsNewSettingsViewController(viewModel: viewModel)

        return viewController
    }
}
