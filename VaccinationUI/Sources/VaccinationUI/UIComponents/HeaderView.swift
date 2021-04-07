//
//  HeaderView.swift
//
//
//  Copyright © 2018 IBM. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
public class HeaderView: MarginableXibView {
    
    // MARK: - Outlets
    
    @IBOutlet public var headline: UILabel!
    @IBOutlet public var actionButton: UIButton!
    
    // MARK: - Variables
    
    public var action: (() -> Void)?
    public var buttonImage: UIImage? { didSet { actionButton.setImage(buttonImage, for: .normal) } }
    
    // MARK: - IBAction
    
    @IBAction public func actionButtonPressed(button: UIButton) { action?() }
}
