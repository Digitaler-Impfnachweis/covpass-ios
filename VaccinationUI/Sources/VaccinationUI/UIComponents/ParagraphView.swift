//
//  ParagraphView.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

import UIKit

@IBDesignable
public class ParagraphView: XibView {
    // MARK: - IBOutlets

    @IBOutlet public var stackView: UIStackView!
    @IBOutlet public var textStackView: UIStackView!
    @IBOutlet public var imageView: UIImageView!
    @IBOutlet public var titleLabel: UILabel!
    @IBOutlet public var bodyLabel: UILabel!
    @IBOutlet public var bottomBorder: UIView!

    // MARK: - Properties

    public var image: UIImage? { didSet { updateView() } }
    public var titleAttributedText: NSAttributedString? { didSet { updateView() } }
    public var bodyAttributedText: NSAttributedString? { didSet { updateView() } }

    // MARK: - Lifecycle

    public override func initView() {
        super.initView()
        contentView?.layoutMargins = .init(top: 0, left: 24, bottom: 0, right: 24)
        stackView.spacing = 15
        textStackView.setCustomSpacing(11, after: bodyLabel)
        bottomBorder.backgroundColor = UIConstants.BrandColor.onBackground20
    }

    // MARK: - Methods
    
    public func showBottomBorder() {
        bottomBorder.isHidden = false
    }

    private func setupAccessibility() {
        let accessibilityLabelText = "\(titleAttributedText?.string ?? "") \(bodyAttributedText?.string ?? "")"
        enableAccessibility(label: accessibilityLabelText, traits: .staticText)
    }

    private func updateView() {
        imageView.image = image
        imageView.isHidden = image == nil
        titleLabel.attributedText = titleAttributedText
        titleLabel.isHidden = titleAttributedText.isNilOrEmpty
        bodyLabel.attributedText = bodyAttributedText
        bodyLabel.isHidden = bodyAttributedText.isNilOrEmpty

        isHidden = imageView.isHidden && titleLabel.isHidden && bodyLabel.isHidden

        setupAccessibility()
    }
}
