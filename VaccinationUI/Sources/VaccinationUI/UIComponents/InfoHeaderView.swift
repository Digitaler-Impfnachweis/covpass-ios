//
//  InfoHeaderView.swift
//
//
//  Copyright © 2018 IBM. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
public class InfoHeaderView: XibView {
    // MARK: - Outlets
    
    @IBOutlet public var headline: UILabel!
    @IBOutlet public var actionButton: UIButton!
    // MARK: - Variables
    
    public var action: (() -> Void)?
    public var buttonImage: UIImage? {
        didSet { actionButton.setImage(buttonImage, for: .normal) }
    }
    public var headlineFont: UIFont? {
        didSet { headline.font = headlineFont }
    }
    
    public var leftMargin: CGFloat = 0
    
//    public override var margins: [Margin] {
//        return [
//            PositionMargin(constant: leftMargin, position: -1, type: .left)
//        ]
//    }
    
    // MARK: - IBAction
    
    @IBAction public func actionButtonPressed(button: UIButton) { action?() }
}
