//
//  String+Localization.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

import UIKit
import VaccinationUI

extension String {
    var localized: String {
        return Localizer.localized(self, bundle: Bundle.module)
    }
}
