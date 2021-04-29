//
//  QRCertificateConfiguration.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

import Foundation
import UIKit
import VaccinationCommon

public class QRCertificateConfiguration: NoCertifiateConfiguration {
    // MARK: - Public Variables
    
    public var stateImage: UIImage?
    public var stateTitle: String?
    public var headerImage: UIImage?
    public var favoriteAction: ((_ certificate: VaccinationCertificate) -> Void)?
    public var qrValue: String?
    public var tintColor: UIColor
    public var certificate: VaccinationCertificate

    // MARK: - Init
    
    public init(certificate: VaccinationCertificate,
                title: String? = "Covid-19 Nachweis".localized,
                image: UIImage? = nil,
                stateImage: UIImage? = nil,
                stateTitle: String = "Impfungen Anzeigen".localized,
                headerImage: UIImage? = nil,
                favoriteAction: ((_ certificate: VaccinationCertificate) -> Void)? = nil,
                backgroundColor: UIColor? = nil,
                tintColor: UIColor = UIColor.black) {
        self.certificate = certificate
        self.stateImage = stateImage
        self.stateTitle = stateTitle
        self.headerImage = headerImage
        self.favoriteAction = favoriteAction
        self.qrValue = certificate.name // we should provide right data here
        self.tintColor = tintColor
        super.init(title: title, subtitle: certificate.name, image: image, identifier: "\(QrCertificateCollectionViewCell.self)")
        self.backgroundColor = backgroundColor
    }
    
    // MARK: - Equatable
    
    public static func == (lhs: QRCertificateConfiguration, rhs: QRCertificateConfiguration) -> Bool {
        return lhs.certificate.name == rhs.certificate.name && lhs.certificate.birthDate == rhs.certificate.birthDate
    }
}
