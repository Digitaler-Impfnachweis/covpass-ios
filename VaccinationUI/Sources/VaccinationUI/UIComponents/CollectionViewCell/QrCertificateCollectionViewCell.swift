//
//  NoCertificateCollectionViewCell.swift
//  
//
//  Copyright © 2021 IBM. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
public class QrCertificateCollectionViewCell: BaseCardCollectionViewCell {
    // MARK: - IBOutlet

    @IBOutlet public var containerView: UIView!
    @IBOutlet public var contentStackView: UIStackView!
    @IBOutlet public var headerView: CardViewHeader!
    @IBOutlet public var actionView: CardViewAction!
    @IBOutlet public var titleView: PlainLabel!
    @IBOutlet public var qrContinerView: QrContinerView!

    // MARK: - Properties

    private let cornerRadius: CGFloat = 14
    private let shadowRadius: CGFloat = 16
    private let shadowOpacity: CGFloat = 0.2
    private let shadowOffset: CGSize = .init(width: 0, height: -4)

    // MARK: - Lifecycle

    public override func awakeFromNib() {
        super.awakeFromNib()
        clipsToBounds = false

        contentView.clipsToBounds = false
        contentView.layer.shadowColor = UIColor.neutralBlack.cgColor
        contentView.layer.shadowRadius = shadowRadius
        contentView.layer.shadowOpacity = Float(shadowOpacity)
        contentView.layer.shadowOffset = shadowOffset

        containerView.layoutMargins = .init(top: .space_30, left: .space_24, bottom: .space_30, right: .space_24)
        containerView.tintColor = .brandAccent
        containerView.layer.cornerRadius = cornerRadius
        containerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onPressAction)))

        contentStackView.setCustomSpacing(.space_20, after: actionView)

        headerView.action = onFavorite
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        contentView.layer.shadowPath = UIBezierPath(roundedRect: containerView.frame, cornerRadius: containerView.layer.cornerRadius).cgPath
    }

    @objc public func onPressAction() {
        self.onAction?()
    }
}

// MARK: - CellConfigutation

extension QrCertificateCollectionViewCell {
    public typealias T = QRCertificateConfiguration

    // TODO refactor this shit to a viewmodel like every other view
    public func configure(with configuration: T) {
        let tintColor: UIColor = configuration.tintColor

        containerView.backgroundColor = configuration.backgroundColor ?? .neutralWhite

        headerView.action = {
            configuration.favoriteAction?(configuration)
        }
        headerView.subtitleLabel.attributedText = configuration.title?.styledAs(.body).colored(tintColor)
        headerView.tintColor = tintColor
        headerView.buttonImage = (configuration.isFavorite ? UIImage.starFull : UIImage.starPartial).withRenderingMode(.alwaysTemplate)
        headerView.buttonTint = configuration.isFullImmunization ? .neutralWhite : .darkText
        contentStackView.setCustomSpacing(.space_12, after: headerView)

        qrContinerView.image = configuration.qrValue?.makeQr(size: UIScreen.main.bounds.size)
        qrContinerView.layoutMargins = .init(top: .space_20, left: .zero, bottom: .space_20, right: .zero)
        qrContinerView.isHidden = configuration.qrValue == nil

        titleView.textableView.attributedText = configuration.subtitle?.styledAs(.header_1).colored(tintColor)
        titleView.backgroundColor = .clear
        contentStackView.setCustomSpacing(.space_12, after: titleView)

        actionView.stateImageView.image = configuration.stateImage
        actionView.titleLabel.attributedText = configuration.stateTitle?.styledAs(.header_3).colored(tintColor)
        actionView.stateImageView.tintColor = tintColor
        actionView.actionButton.tintColor = tintColor
        actionView.tintColor = .neutralWhite

        layoutIfNeeded()
    }
}
