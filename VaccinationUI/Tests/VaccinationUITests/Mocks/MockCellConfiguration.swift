
//  MockCellConfiguration.swift
//
//
//  Created by Daniel on 19.04.2021.
//

import Foundation
import UIKit
import VaccinationUI

class MockCellConfiguration {
    
    static func noCertificateConfiguration() -> NoCertifiateConfiguration {
        return NoCertifiateConfiguration(title: "Title", subtitle: "Subtitle", image: UIImage())
    }
    
    static func qrCertificateConfiguration() -> QRCertificateConfiguration {
        QRCertificateConfiguration(
            image: .starEmpty,
            stateImage: .halfShield,
            headerImage: .starEmpty,
            favoriteAction: nil,
            backgroundColor: .onBackground50)
    }
}
