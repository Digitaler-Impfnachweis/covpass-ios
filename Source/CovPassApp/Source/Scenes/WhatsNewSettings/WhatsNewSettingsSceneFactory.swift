//
//  WhatsNewSettingsSceneFactory.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import CovPassUI
import Foundation
import UIKit

struct WhatsNewSettingsSceneFactory: SceneFactory {
    private let router: WhatsNewSettingsRouterProtocol

    init(router: WhatsNewSettingsRouterProtocol) {
        self.router = router
    }

    func make() -> UIViewController {
        let bundle = Bundle.commonBundle
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
