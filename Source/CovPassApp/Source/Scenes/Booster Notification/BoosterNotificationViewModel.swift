//
//  BoosterNotificationViewModel.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import PromiseKit

final class BoosterNotificationViewModel {

    let resolver: Resolver<Void>

    var title: String {
        "dialog_booster_vaccination_notification_title".localized
    }

    var actionButtonTitle: String {
        "dialogue_add_booster_vaccination_action_button_title".localized
    }

    var disclaimerText: String {
        "dialog_booster_vaccination_notification_message".localized
    }

    init(resolvable: Resolver<Void>) {
        resolver = resolvable
    }
}
