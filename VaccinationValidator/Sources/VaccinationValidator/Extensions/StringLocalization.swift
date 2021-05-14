//
//  String+Localization.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import UIKit
import VaccinationUI

extension String {
    var localized: String {
        return Localizer.localized(self, bundle: Bundle.module)
    }
}
