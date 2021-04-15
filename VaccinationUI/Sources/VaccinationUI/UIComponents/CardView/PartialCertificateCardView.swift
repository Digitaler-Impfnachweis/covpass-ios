//
//  PartialCertificateCardView.swift
//  
//
//  Copyright © 2021 IBM. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
public class PartialCertificateCardView: BaseCardView {
    // MARK: - Outlets
    
    @IBOutlet public var headerView: CardViewHeader!
    @IBOutlet public var actionView: CardViewAction!
    @IBOutlet public var continerView: UIView!
    @IBOutlet public var actionButton: PrimaryButtonContainer!
}
