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
        stackView.setCustomSpacing(20, after: actionView)
        actionView.tintColor = UIConstants.BrandColor.brandAccent
        actionView.tintColor = UIConstants.BrandColor.brandAccent
        qrContinerView.titleLabel.font = UIConstants.Font.semiBoldLarger
        qrContinerView.subtitleLabel.font = UIConstants.Font.regular
        actionView.action = onAction
        headerView.action = onFavorite
    }
}

// MARK: - CellConfigutation

extension QrCertificateCollectionViewCell {
    public typealias T = QRCertificateConfiguration
    
    public func configure(with configuration: T) {
        contentView.layoutMargins = .init(top: 30, left: 24, bottom: 30, right: 24)

        headerView.action = configuration.headerAction
        headerView.titleLabel.text = configuration.subtitle
        headerView.subtitleLabel.text = configuration.title
        headerView.titleLabel.textColor = configuration.qrViewConfiguration?.tintColor
        headerView.subtitleLabel.textColor = configuration.qrViewConfiguration?.tintColor
        headerView.tintColor = configuration.qrViewConfiguration?.tintColor
        stackView.setCustomSpacing(30, after: headerView)

        actionView.action = configuration.stateAction
        actionView.stateImageView.image = configuration.stateImage
        actionView.titleLabel.text = configuration.stateTitle
        actionView.titleLabel.textColor = configuration.qrViewConfiguration?.tintColor
        actionView.stateImageView.tintColor = configuration.qrViewConfiguration?.tintColor
        actionView.actionButton.tintColor = configuration.qrViewConfiguration?.tintColor
        actionView.tintColor = configuration.qrViewConfiguration?.tintColor

        cardBackgroundColor = configuration.backgroundColor ?? UIColor.white

        qrContinerView.qrImageView.image = configuration.qrViewConfiguration?.qrValue?.makeQr(size: qrContinerView.qrImageView.bounds.size)
        qrContinerView.titleLabel.text = configuration.qrViewConfiguration?.qrTitle
        qrContinerView.subtitleLabel.text = configuration.qrViewConfiguration?.qrSubtitle
        qrContinerView.isHidden = configuration.qrViewConfiguration == nil
    }
}
