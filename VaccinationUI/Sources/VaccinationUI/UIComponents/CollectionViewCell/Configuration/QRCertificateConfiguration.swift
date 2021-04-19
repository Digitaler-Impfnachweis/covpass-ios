//
//  QRCertificateConfiguration.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

import Foundation
import UIKit


public class QrViewConfiguration {
    public var tintColor: UIColor?
    public var qrValue: String?
    public var qrTitle: String?
    public var qrSubtitle: String?
    
    public init(tintColor: UIColor?, qrValue: String?, qrTitle: String?, qrSubtitle: String?) {
        self.tintColor = tintColor
        self.qrValue = qrValue
        self.qrTitle = qrTitle
        self.qrSubtitle = qrSubtitle
    }
}

public class QRCertificateConfiguration: NoCertifiateConfiguration {
    public var stateImage: UIImage?
    public var stateTitle: String?
    public var stateAction: (() -> Void)?
    public var headerImage: UIImage?
    public var headerAction: (() -> Void)?
    public var qrViewConfiguration: QrViewConfiguration?
    
    // MARK: - Init
    
    public init(title: String?, subtitle: String?, image: UIImage?, stateImage: UIImage?, stateTitle: String?, stateAction: (() -> Void)?, headerImage: UIImage?, headerAction: (() -> Void)?, backgroundColor: UIColor?, qrViewConfiguration: QrViewConfiguration?) {
        super.init(title: title, subtitle: subtitle, image: image)
        self.stateImage = stateImage
        self.stateTitle = stateTitle
        self.stateAction = stateAction
        self.headerImage = headerImage
        self.headerAction = headerAction
        self.backgroundColor = backgroundColor
        self.qrViewConfiguration = qrViewConfiguration
    }
}
