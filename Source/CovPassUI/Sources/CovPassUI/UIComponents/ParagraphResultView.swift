//
//  ParagraphResultView.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import UIKit

@IBDesignable
public class ParagraphResultView: XibView {
    // MARK: - IBOutlets

    @IBOutlet public var stackView: UIStackView!
    @IBOutlet public var textStackView: UIStackView!
    @IBOutlet public var imageView: UIImageView!
    @IBOutlet public var titleLabel: UILabel!
    @IBOutlet public var bodyLabel: UILabel!
    @IBOutlet public var infoStackView: UIStackView!
    @IBOutlet public var bottomBorder: UIView!
    @IBOutlet public var bottomConstraint: NSLayoutConstraint!

    // MARK: - Properties

    public var image: UIImage? { didSet { updateView() } }
    public var attributedTitleText: NSAttributedString? { didSet { updateView() } }
    public var attributedBodyText: NSAttributedString? { didSet { updateView() } }
    public var resultFail = [String]() { didSet { updateView() } }
    public var resultOpen = [String]() { didSet { updateView() } }

    // MARK: - Lifecycle

    override public func initView() {
        super.initView()
        backgroundColor = .neutralWhite
        contentView?.layoutMargins = .init(top: .zero, left: .space_24, bottom: .zero, right: .space_24)
        stackView.spacing = .space_24
        bottomBorder.backgroundColor = .onBackground20
        layoutMargins.top = .space_12
    }

    // MARK: - Methods

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

        infoStackView.isHidden = resultFail.isEmpty && resultOpen.isEmpty
        infoStackView.subviews.forEach { subview  in
            subview.removeFromSuperview()
            infoStackView.removeArrangedSubview(subview)
        }
        bottomConstraint.constant = infoStackView.isHidden ? 0.0 : 8.0

        for fail in resultFail {
            let info = PlainLabel()
            info.attributedText = fail.styledAs(.body)
            info.layoutMargins = .init(top: .space_16, left: .space_16, bottom: .space_16, right: .space_16)
            info.backgroundColor = .resultRedBackground
            info.layer.borderWidth = 1.0
            info.layer.borderColor = UIColor.resultRed.cgColor
            info.layer.cornerRadius = 12.0
            infoStackView.addArrangedSubview(info)
        }

        for open in resultOpen {
            let info = PlainLabel()
            info.attributedText = open.styledAs(.body)
            info.layoutMargins = .init(top: .space_16, left: .space_16, bottom: .space_16, right: .space_16)
            info.backgroundColor = .resultYellowBackground
            info.layer.borderWidth = 1.0
            info.layer.borderColor = UIColor.resultYellow.cgColor
            info.layer.cornerRadius = 12.0
            infoStackView.addArrangedSubview(info)
        }

        setupAccessibility()
    }
}
