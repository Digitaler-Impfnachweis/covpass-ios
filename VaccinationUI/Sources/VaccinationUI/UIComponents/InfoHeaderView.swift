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
    
    @IBOutlet public var textLabel: UILabel!
    @IBOutlet public var actionButton: UIButton!

    // MARK: - Variables

    public var attributedTitleText: NSAttributedString? {
        didSet {
            textLabel.attributedText = attributedTitleText
        }
    }

    public var image: UIImage? {
        didSet {
            actionButton.setImage(image, for: .normal)
        }
    }
    
    public var action: (() -> Void)?

    // MARK: - Lifecycle

    public override func initView() {
        super.initView()
        layoutMargins = .init(top: .zero, left: .space_24, bottom: .zero, right: .space_24)
    }

    // MARK: - IBAction
    
    @IBAction public func actionButtonPressed(button: UIButton) { action?() }
}
