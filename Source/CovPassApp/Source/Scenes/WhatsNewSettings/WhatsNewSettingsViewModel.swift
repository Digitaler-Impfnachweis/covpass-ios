//
//  WhatsNewSettingsViewModel.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import Foundation

private enum Constants {
    static let header = "app_information_title_update_notifications".localized
    static let description = "app_information_copy_update_notifications".localized
    static let switchTitle = "app_information_update_notifications_toggle".localized
    static let accessibilityAnnouncementOpen = "accessibility_app_information_update_notifications_announce_open".localized
    static let accessibilityAnnouncementClose = "accessibility_app_information_update_notifications_announce_close".localized
}

final class WhatsNewSettingsViewModel: WhatsNewSettingsViewModelProtocol {
    let accessibilityAnnouncementOpen = Constants.accessibilityAnnouncementOpen
    let accessibilityAnnouncementClose = Constants.accessibilityAnnouncementClose
    let header = Constants.header
    let description = Constants.description
    let switchTitle = Constants.switchTitle
    let whatsNewURLRequest: URLRequest

    var disableWhatsNew: Bool {
        get {
            persistence.disableWhatsNew
        }
        set {
            persistence.disableWhatsNew = newValue
        }
    }

    private var persistence: Persistence

    init(persistence: Persistence, whatsNewURL: URL) {
        self.persistence = persistence
        whatsNewURLRequest = .init(url: whatsNewURL)
    }
}
