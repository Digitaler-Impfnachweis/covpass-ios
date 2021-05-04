//
//  CardViewHeader.swift
//  
//
//  Copyright © 2021 IBM. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
public class CardViewHeader: XibView {
    // MARK: - Outlets

    @IBOutlet public var stackView: UIStackView!
    @IBOutlet public var subtitleStackView: UIStackView!
    @IBOutlet public var subtitleLabel: UILabel!
    @IBOutlet public var titleLabel: UILabel!
    @IBOutlet public var leftButton: UIButton!
    
    // MARK: - Variables
    
    public var action: (() -> Void)?
    public var buttonImage: UIImage? {
        didSet { leftButton.setImage(buttonImage, for: .normal) }
    }
    
    // MARK: - IBAction
    
    @IBAction public func infoButtonPressed(button: UIButton) {
        action?()
    }

    public override func initView() {
        super.initView()
        stackView.spacing = .space_24
        subtitleStackView.spacing = .space_12
    }
}
