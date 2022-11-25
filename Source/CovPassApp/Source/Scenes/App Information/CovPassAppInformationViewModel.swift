//
//  CovPassAppInformationViewModel.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import CovPassUI

private enum Constants {
    static let whatsNewTitle = "app_information_list_update_notifications".localized
    static let whatsNewOn = "settings_list_status_on".localized
    static let whatsNewOff = "settings_list_status_off".localized
}

class CovPassAppInformationViewModel: AppInformationBaseViewModel {
    override var entries: [AppInformationEntry] {
        super.entries + [whatsNewEntry]
    }

    internal var whatsNewEntry: AppInformationEntry {
        let router = WhatsNewSettingsRouter(sceneCoordinator: router.sceneCoordinator)
        let scene = WhatsNewSettingsSceneFactory(router: router)
        let rightTitle = persistence.disableWhatsNew ?
            Constants.whatsNewOff :
            Constants.whatsNewOn

        return .init(
            title: Constants.whatsNewTitle,
            scene: scene,
            rightTitle: rightTitle
        )
    }

    internal let persistence: Persistence

    init(
        router: AppInformationRouterProtocol,
        persistence: Persistence
    ) {
        self.persistence = persistence
        super.init(router: router)
    }
}
