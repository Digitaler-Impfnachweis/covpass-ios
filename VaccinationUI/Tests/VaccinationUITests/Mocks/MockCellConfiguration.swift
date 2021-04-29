
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
        let image = UIImage(named: UIConstants.IconName.StarEmpty, in: UIConstants.bundle, compatibleWith: nil)
        let stateImage = UIImage(named: UIConstants.IconName.HalfShield, in: UIConstants.bundle, compatibleWith: nil)
        let headerImage = UIImage(named: UIConstants.IconName.StarEmpty, in: UIConstants.bundle, compatibleWith: nil)
        return QRCertificateConfiguration(
            image: image,
            stateImage: stateImage,
            headerImage: headerImage,
            favoriteAction: nil,
            backgroundColor: UIConstants.BrandColor.onBackground50)
    }
}
