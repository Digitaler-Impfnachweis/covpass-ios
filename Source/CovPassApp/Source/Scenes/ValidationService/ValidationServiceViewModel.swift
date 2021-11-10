//
//  ValidationServiceViewModel.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import CovPassCommon

struct ValidationServiceViewModel {

    let router: ValidationServiceRouter

    internal init(router: ValidationServiceRouter, initialisationData: ValidationServiceInitialisation) {
        self.router = router
        self.initialisationData = initialisationData
    }


    let initialisationData: ValidationServiceInitialisation

    var numberOfSections: Int {
        1
    }

    var numberOfRows: Int {
        4
    }
}
