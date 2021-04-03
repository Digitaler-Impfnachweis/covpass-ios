//
//  PartialCertifiateCardView.swift
//  
//
//  Copyright © 2021 IBM. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
public class PartialCertifiateCardView: MarginableXibView {
    
    // MARK: - Outlets
    
    @IBOutlet public var headerView: CardViewHeader!
    @IBOutlet public var actionView: CardViewAction!
    @IBOutlet public var continerView: UIView!
    @IBOutlet public var actionButton: PrimaryIconButtonContainer!
    
    // MARK: - IBInspectable

    @IBInspectable public var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
            layer.masksToBounds = cornerRadius > 0
        }
    }
    @IBInspectable public var borderWidth: CGFloat = 0 {
        didSet { layer.borderWidth = borderWidth }
    }
    @IBInspectable public var borderColor: UIColor? {
        didSet { layer.borderColor = borderColor?.cgColor }
    }
    @IBInspectable public var cardBackgroundColor: UIColor = UIColor.green {
        didSet { backgroundColor = cardBackgroundColor }
    }
    @IBInspectable public var cardTintColor: UIColor = UIColor.systemBlue {
        didSet { backgroundColor = cardTintColor }
    }
    
    // MARK: - Lifecycle
    
    override public func initView() {
        super.initView()
        
        actionButton.action = {
            print("Hello World")
        }
        actionButton.title = "2. Impfung hinzufügen"
    }
}
