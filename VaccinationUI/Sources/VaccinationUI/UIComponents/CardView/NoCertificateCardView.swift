//
//  NoCertificateCardView.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
public class NoCertificateCardView: BaseCardView {
    // MARK: - Outlets
    
    @IBOutlet public var topImageView: UIImageView!
    @IBOutlet public var titleLabel: UILabel!
    @IBOutlet public var textLable: UILabel!
    @IBOutlet public var actionButton: PrimaryButtonContainer!
}
