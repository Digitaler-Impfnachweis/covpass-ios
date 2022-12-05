//
//  AnnouncementViewModel.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import Foundation
import PromiseKit

private enum Constants {
    static let checkboxTitle = "whats_new_screen_update_notifications_checkbox_headline".localized(bundle: .main)
    static let checkboxDescription = "whats_new_screen_update_notifications_checkbox_copy".localized.localized(bundle: .main)
    static let okButtonTitle = "dialog_update_info_notification_action_button".localized.localized(bundle: .main)
    static let switchOn = "settings_list_status_on".localized.localized(bundle: .main)
    static let switchOff = "settings_list_status_off".localized.localized(bundle: .main)
}

final class AnnouncementViewModel: AnnouncementViewModelProtocol {
    // MARK: - Properties

    let checkboxTitle = Constants.checkboxTitle
    let checkboxDescription = Constants.checkboxDescription
    let okButtonTitle = Constants.okButtonTitle
    let whatsNewURL: URL

    var disableWhatsNew: Bool {
        get {
            persistence.disableWhatsNew
        }
        set {
            persistence.disableWhatsNew = newValue
        }
    }

    var checkboxAccessibilityValue: String {
        disableWhatsNew ? Constants.switchOn : Constants.switchOff
    }

    private let router: AnnouncementRouter
    private let resolver: Resolver<Void>
    private var persistence: Persistence

    // MARK: - Lifecycle

    init(
        router: AnnouncementRouter,
        resolvable: Resolver<Void>,
        persistence: Persistence,
        whatsNewURL: URL
    ) {
        self.persistence = persistence
        self.whatsNewURL = whatsNewURL
        self.router = router
        resolver = resolvable
    }

    func done() {
        resolver.fulfill_()
    }

    func cancel() {
        resolver.fulfill_()
    }
}
