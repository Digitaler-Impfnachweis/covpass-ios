//
//  MockCellConfiguration.swift
//  
//
//  Created by Daniel on 19.04.2021.
//

import Foundation
import UIKit
import VaccinationPass
import VaccinationUI
import VaccinationCommon

class MockCellConfiguration {
    static func noCertificateConfiguration() -> NoCertifiateConfiguration {
        return NoCertifiateConfiguration(title: "Title", subtitle: "Subtitle", image: UIImage())
    }
}
