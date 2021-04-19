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
    
    public var stateImage: UIImage?
    public var stateTitle: String?
    public var stateAction: (() -> Void)?
    public var headerImage: UIImage?
    public var headerAction: (() -> Void)?
    public var qrViewConfiguration: QrViewConfiguration?
    
    // MARK: - Init
    
    public init(title: String?, subtitle: String?, image: UIImage?, stateImage: UIImage?, stateTitle: String?, stateAction: (() -> Void)?, headerImage: UIImage?, headerAction: (() -> Void)?, backgroundColor: UIColor?, qrViewConfiguration: QrViewConfiguration?) {
        self.stateImage = stateImage
        self.stateTitle = stateTitle
        self.stateAction = stateAction
        self.headerImage = headerImage
        self.headerAction = headerAction
        self.qrViewConfiguration = qrViewConfiguration
        super.init(title: title, subtitle: subtitle, image: image, identifier: "\(QrCertificateCollectionViewCell.self)")
        self.backgroundColor = backgroundColor
    }
}
