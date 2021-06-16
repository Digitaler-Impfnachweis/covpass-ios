//
//  String+Localization.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassUI
import UIKit

extension String {
    var localized: String {
        Localizer.localized(self, bundle: Bundle.main)
    }
}
