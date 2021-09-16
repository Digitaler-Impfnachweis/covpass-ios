//
//  BoosterDisclaimerViewModel.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import PromiseKit

final class BoosterDisclaimerViewModel {
    let resolver: Resolver<Void>

    var title: String {
        "booster_vaccination_certificate_overview_title".localized
    }

    var actionButtonTitle: String {
        "booster_vaccination_certificate_overview_action_button_title".localized
    }

    var disclaimerText: String {
        "booster_vaccination_certificate_overview_message".localized
    }

    init(resolvable: Resolver<Void>) {
        resolver = resolvable
    }
}
