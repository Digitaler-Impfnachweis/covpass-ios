//
//  ConfirmView.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

import UIKit

public class ConfirmView: XibView {
    // MARK: - IBOutlets

    @IBOutlet public var detailLabel: UILabel!
    @IBOutlet public var infoLabel: UILabel!
    @IBOutlet public var imageView: UIImageView!
    @IBOutlet public var stackView: UIStackView!

    @IBOutlet public var imageWidthConstraint: NSLayoutConstraint!
    @IBOutlet public var imageHeightConstraint: NSLayoutConstraint!

    // MARK: - Public

    public enum ConfirmType {
        case placeholder(image: UIImage?)
        case custom(image: UIImage?, width: CGFloat = UIConstants.Size.ConfirmImageWidth, height: CGFloat = UIConstants.Size.ConfirmImageHeight)
    }

    public var kind: ConfirmType = .placeholder(image: UIImage()) {
        didSet {
            updateImageView()
            updateDetailFont()
        }
    }

    public var detail: String? {
        get {
            detailLabel.text
        }
        set {
            detailLabel.isHidden = newValue?.isEmpty ?? true
            detailLabel.text = newValue
        }
    }

    public var info: String? {
        get {
            infoLabel.text
        }
        set {
            infoLabel.isHidden = newValue?.isEmpty ?? true
            if let infoText = newValue, let font = infoLabel.font,
                let textColor = infoLabel.textColor, !infoText.isEmpty {
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.lineSpacing = UIConstants.Size.TextLineSpacing
                paragraphStyle.alignment = .center
                let attributes: [NSAttributedString.Key: Any] = [
                    .paragraphStyle: paragraphStyle,
                    .font: font,
                    .foregroundColor: textColor
                ]
                infoLabel.attributedText = NSAttributedString(string: infoText, attributes: attributes)
            } else {
                infoLabel.text = newValue
            }
        }
    }

    public var spacing: CGFloat {
        get {
            stackView.spacing
        }
        set {
            stackView.spacing = newValue
        }
    }

    // MARK: - Init

    /**
     Setup appearence of all subviews such as fonts, colors, borders
     */
    public override func initView() {
        super.initView()

        updateImageView()
        detailLabel.font = UIConstants.Font.regularLarger
        detailLabel.adjustsFontForContentSizeCategory()
        detailLabel.textColor = UIConstants.BrandColor.onBackground100
        infoLabel.font = UIConstants.Font.regular
        infoLabel.adjustsFontForContentSizeCategory()
        infoLabel.textColor = UIConstants.BrandColor.onBackground70
        infoLabel.isHidden = true
    }

    public func setDetailLabel(font: UIFont) {
        detailLabel.font = UIFontMetrics.default.scaledFont(for: font)
    }

    // MARK: - Private

    private func updateImageView() {
        imageView.tintColor = UIConstants.BrandColor.onBrandAccent70
        switch kind {
        case let .placeholder(image):
            imageView.image = image?.withRenderingMode(.alwaysTemplate)
            imageView.tintColor = UIConstants.BrandColor.onBackground50
        case let .custom(image, _, _):
            imageView.image = image
        }

        switch kind {
        case .placeholder:
            imageWidthConstraint.constant = UIConstants.Size.PlaceholderImageWidth
            imageHeightConstraint.constant = UIConstants.Size.PlaceholderImageHeight
        case let .custom(_, width, height):
            imageWidthConstraint.constant = width
            imageHeightConstraint.constant = height
        }
    }

    private func updateDetailFont() {
        switch kind {
        case .custom:
            detailLabel.font = UIConstants.Font.regularLarger
        case .placeholder:
            detailLabel.font = UIConstants.Font.semiBoldLarger
        }
        detailLabel.adjustsFontForContentSizeCategory()
    }
}

extension ConfirmView.ConfirmType: Equatable {
    public static func == (lhs: ConfirmView.ConfirmType, rhs: ConfirmView.ConfirmType) -> Bool {
        switch (lhs, rhs) {
        case (let .custom(lhsImage, lhsWidth, lhsHeight), let .custom(rhsImage, rhsWidth, rhsHeight)):
            return lhsImage == rhsImage && lhsWidth == rhsWidth && lhsHeight == rhsHeight
        case let (.placeholder(lhsImage), .placeholder(rhsImage)):
            return lhsImage == rhsImage
        default:
            return false
        }
    }
}
