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

    @IBOutlet public var stackView: UIStackView!
    @IBOutlet public var headerView: CardViewHeader!
    @IBOutlet public var actionView: CardViewAction!
    @IBOutlet public var qrContinerView: QrContinerView!

    // MARK: - Lifecycle

    public override func awakeFromNib() {
        super.awakeFromNib()
        stackView.setCustomSpacing(.space_20, after: actionView)
        actionView.action = onAction
        headerView.action = onFavorite
        cardTintColor = .brandAccent
        cardBackgroundColor = .brandAccent
        cornerRadius = 15
    }
}

// MARK: - CellConfigutation

extension QrCertificateCollectionViewCell {
    public typealias T = QRCertificateConfiguration
    
    public func configure(with configuration: T) {
        contentView.layoutMargins = .init(top: .space_30, left: .space_24, bottom: .space_30, right: .space_24)
        let tintColor: UIColor = configuration.qrViewConfiguration?.tintColor ?? .neutralBlack

        headerView.action = configuration.headerAction
        headerView.titleLabel.attributedText = configuration.subtitle?.toAttributedString(.h3).colored(tintColor)
        headerView.subtitleLabel.attributedText = configuration.title?.toAttributedString(.body).colored(tintColor)
        headerView.tintColor = tintColor
        stackView.setCustomSpacing(.space_30, after: headerView)

        actionView.action = configuration.stateAction
        actionView.stateImageView.image = configuration.stateImage
        actionView.titleLabel.attributedText = configuration.stateTitle?.toAttributedString(.h5).colored(tintColor)
        actionView.stateImageView.tintColor = tintColor
        actionView.actionButton.tintColor = tintColor
        actionView.tintColor = .neutralWhite

        cardBackgroundColor = configuration.backgroundColor ?? .neutralWhite

        qrContinerView.image = configuration.qrViewConfiguration?.qrValue?.makeQr(size: UIScreen.main.bounds.size)
        qrContinerView.title = configuration.qrViewConfiguration?.qrTitle
        qrContinerView.subtitle = configuration.qrViewConfiguration?.qrSubtitle
        qrContinerView.isHidden = configuration.qrViewConfiguration == nil
        qrContinerView.layoutMargins = .init(top: .space_20, left: .space_24, bottom: .zero, right: .space_24)
    }
}
