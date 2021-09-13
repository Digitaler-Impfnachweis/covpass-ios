//
//  ApiServiceFactory.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import Foundation

extension BoosterLogic {
    static func create() -> BoosterLogic {
        BoosterLogic(
            certLogic: DCCCertLogic.create(),
            userDefaults: UserDefaultsPersistence()
        )
    }
}
