//
//  QRCertificateConfiguration.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

import Foundation
import UIKit

public class QRCertificateConfiguration: NoCertifiateConfiguration {
    // MARK: - Public Variables
    
    public var qrValue: String?
    public var stateImage: UIImage?
    public var stateTitle: String?
    public var headerImage: UIImage?
    public var favoriteAction: ((_ configuration: QRCertificateConfiguration) -> Void)?
    public var tintColor: UIColor

    // MARK: - Init
    
    public init(qrValue: String? = nil,
                title: String? = nil,
                subtitle: String? = nil,
                image: UIImage? = nil,
                stateImage: UIImage? = nil,
                stateTitle: String? = nil,
                headerImage: UIImage? = nil,
                favoriteAction: ((_ configuration: QRCertificateConfiguration) -> Void)? = nil,
                backgroundColor: UIColor? = nil,
                tintColor: UIColor = UIColor.black) {
        self.stateImage = stateImage
        self.stateTitle = stateTitle
        self.headerImage = headerImage
        self.favoriteAction = favoriteAction
        self.qrValue = qrValue
        self.tintColor = tintColor
        super.init(title: title, subtitle: subtitle, image: image, identifier: "\(QrCertificateCollectionViewCell.self)")
        self.backgroundColor = backgroundColor
    }
    
    // MARK: - Equatable
    
    public static func == (lhs: QRCertificateConfiguration, rhs: QRCertificateConfiguration) -> Bool {
        return lhs.title == rhs.title && lhs.subtitle == rhs.subtitle && lhs.qrValue == rhs.qrValue
    }
}
