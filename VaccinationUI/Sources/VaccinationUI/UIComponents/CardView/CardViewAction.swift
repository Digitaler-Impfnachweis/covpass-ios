//
//  CardViewAction.swift
//  
//
//  Copyright © 2021 IBM. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
public class CardViewAction: XibView {
    // MARK: - Outlets
    
    @IBOutlet public var titleLabel: UILabel!
    @IBOutlet public var actionButton: UIButton!
    @IBOutlet public var stateImageView: UIImageView!
    
    // MARK: - Variables
    
    public var action: (() -> Void)?
    public var buttonImage: UIImage? { didSet { actionButton.setImage(buttonImage, for: .normal) } }
    
    // MARK: - IBAction
    
    @IBAction public func actionButtonPressed(button: UIButton) { action?() }
}
