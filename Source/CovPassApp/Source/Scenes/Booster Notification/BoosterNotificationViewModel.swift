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
        "".localized
    }

    var actionButtonTitle: String {
        "".localized
    }

    var disclaimerText: String {
        "".localized
    }

    init(resolvable: Resolver<Void>) {
        resolver = resolvable
    }
}
