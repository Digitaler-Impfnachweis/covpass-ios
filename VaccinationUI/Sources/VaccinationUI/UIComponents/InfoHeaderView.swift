//
//  InfoHeaderView.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
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

    public var labelUserInteractionEnabled: Bool? {
        didSet {
            let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(InfoHeaderView.textButtonPressed))
            textLabel.isUserInteractionEnabled = labelUserInteractionEnabled ?? false
            textLabel.addGestureRecognizer(gestureRecognizer)
        }
    }

    public var action: (() -> Void)?

    // MARK: - Lifecycle

    override public func initView() {
        super.initView()
        layoutMargins = .init(top: .zero, left: .space_24, bottom: .zero, right: .space_24)
    }

    // MARK: - IBAction

    @IBAction public func actionButtonPressed(button _: UIButton) { action?() }

    @IBAction public func textButtonPressed(sender: UITapGestureRecognizer) { action?() }
}
