//
//  WhatsNewSettingsViewModel.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import Foundation

private enum Constants {
    static let header = "app_information_title_update_notifications".localized(bundle: .main)
    static let description = "app_information_copy_update_notifications".localized(bundle: .main)
    static let switchTitle = "app_information_update_notifications_toggle".localized(bundle: .main)
    static let accessibilityAnnouncementOpen = "accessibility_app_information_update_notifications_announce_open".localized(bundle: .main)
    static let accessibilityAnnouncementClose = "accessibility_app_information_update_notifications_announce_close".localized(bundle: .main)
}

public class WhatsNewSettingsViewModel: WhatsNewSettingsViewModelProtocol {
    public let accessibilityAnnouncementOpen = Constants.accessibilityAnnouncementOpen
    public let accessibilityAnnouncementClose = Constants.accessibilityAnnouncementClose
    public let header = Constants.header
    public let description = Constants.description
    public let switchTitle = Constants.switchTitle
    public let whatsNewURLRequest: URLRequest

    public var disableWhatsNew: Bool {
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
