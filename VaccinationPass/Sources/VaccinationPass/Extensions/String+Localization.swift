//
//  File.swift
//  
//
//  Created by Gabriela Secelean on 15.04.2021.
//

import UIKit
import VaccinationUI

extension String {
    var localized: String {
        return Localizer.localized(self, bundle: Bundle.module)
    }
}
