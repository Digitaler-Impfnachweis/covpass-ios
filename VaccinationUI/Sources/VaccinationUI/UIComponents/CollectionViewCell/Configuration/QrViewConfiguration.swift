//
//  QrViewConfiguration.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

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
