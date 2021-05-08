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
    public var attributedTitleText: NSAttributedString? { didSet { updateView() } }
    public var attributedBodyText: NSAttributedString? { didSet { updateView() } }

    // MARK: - Lifecycle

    override public func initView() {
        super.initView()
        backgroundColor = .neutralWhite
        contentView?.layoutMargins = .init(top: .zero, left: .space_24, bottom: .zero, right: .space_24)
        stackView.spacing = .space_24
        bottomBorder.backgroundColor = .onBackground20
    }

    // MARK: - Methods

    public func showBottomBorder() {
        bottomBorder.isHidden = false
    }

    private func setupAccessibility() {
        let accessibilityLabelText = "\(attributedTitleText?.string ?? "") \(attributedBodyText?.string ?? "")"
        enableAccessibility(label: accessibilityLabelText, traits: .staticText)
    }

    private func updateView() {
        imageView.image = image
        imageView.isHidden = image == nil
        titleLabel.attributedText = attributedTitleText
        titleLabel.isHidden = attributedTitleText.isNilOrEmpty
        bodyLabel.attributedText = attributedBodyText
        bodyLabel.isHidden = attributedBodyText.isNilOrEmpty

        isHidden = titleLabel.isHidden && bodyLabel.isHidden

        setupAccessibility()
    }
}
