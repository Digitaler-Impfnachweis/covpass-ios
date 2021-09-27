//
//  CertificateCollectionViewCell.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import Foundation
import UIKit

private enum Constants {
    static let qrInfoText = "certificates_overview_qr_scan_hint".localized
    enum Accessibility {}
}

public typealias CertificateCardViewModelProtocol = CardViewModel & CertificateCardViewModelBase

public protocol CertificateCardViewModelBase {
    var title: String { get }
    var subtitle: String { get }
    var titleIcon: UIImage { get }
    var isExpired: Bool { get }
    var isBoosted: Bool { get }
    var isFavorite: Bool { get }
    var showFavorite: Bool { get set }
    var qrCode: UIImage? { get }
    var name: String { get }
    var actionTitle: String { get }
    var tintColor: UIColor { get }
    var isFullImmunization: Bool { get }
    var vaccinationDate: Date? { get }
    var delegate: ViewModelDelegate? { get set }
    func onClickAction()
    func onClickFavorite()
}

@IBDesignable
public class CertificateCollectionViewCell: CardCollectionViewCell {
    // MARK: - IBOutlet

    @IBOutlet public var containerView: UIView!
    @IBOutlet public var contentStackView: UIStackView!
    @IBOutlet public var titleStackView: UIStackView!
    @IBOutlet public var actionView: CardViewAction!
    @IBOutlet public var titleView: PlainLabel!
    @IBOutlet public var qrContainerView: QRContainerView!
    @IBOutlet public var favoriteButton: UIButton!

    // MARK: - Public Properties

    override public var viewModel: CardViewModel? {
        didSet {
            updateView()
        }
    }

    // MARK: - Private Properties

    private let cornerRadius: CGFloat = 26
    private let shadowRadius: CGFloat = 16
    private let shadowOpacity: CGFloat = 0.2
    private let shadowOffset: CGSize = .init(width: 0, height: -4)
    private let titleLineHieght: CGFloat = 33

    // MARK: - Lifecycle

    override public func awakeFromNib() {
        super.awakeFromNib()
        clipsToBounds = false

        contentView.clipsToBounds = false
        contentView.layer.shadowColor = UIColor.neutralBlack.cgColor
        contentView.layer.shadowRadius = shadowRadius
        contentView.layer.shadowOpacity = Float(shadowOpacity)
        contentView.layer.shadowOffset = shadowOffset

        containerView.tintColor = .brandAccent
        containerView.layer.cornerRadius = cornerRadius
        containerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onPressAction)))

        contentStackView.setCustomSpacing(.space_8, after: titleStackView)
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        contentView.layer.shadowPath = UIBezierPath(roundedRect: containerView.frame, cornerRadius: containerView.layer.cornerRadius).cgPath
    }

    private func updateView() {
        guard let vm = viewModel as? CertificateCardViewModelProtocol else { return }

        containerView.backgroundColor = vm.backgroundColor

        qrContainerView.icon = vm.titleIcon
        qrContainerView.iconView?.tintColor = vm.iconTintColor
        qrContainerView.image = vm.qrCode
        qrContainerView.layoutMargins.bottom = .space_18
        qrContainerView.isHidden = vm.qrCode == nil
        qrContainerView.titleLabel.attributedText = vm.title.styledAs(.header_2).colored(vm.textColor)
        qrContainerView.subtitleLabel.attributedText = vm.subtitle.styledAs(.body).colored(vm.textColor)

        qrContainerView.qrInfoText = Constants.qrInfoText

        qrContainerView.showOverlay = vm.isExpired

        titleView.textableView.attributedText = vm.name.styledAs(.header_1).lineHeight(titleLineHieght).colored(vm.tintColor)
        titleView.backgroundColor = .clear
        favoriteButton.tintColor = vm.tintColor
        favoriteButton.setImage((vm.isFavorite ? UIImage.starFull : UIImage.starPartial).withRenderingMode(.alwaysTemplate), for: .normal)
        favoriteButton.isHidden = !vm.showFavorite
        contentStackView.setCustomSpacing(.space_2, after: titleView)

        actionView.titleLabel.attributedText = vm.actionTitle.styledAs(.body).colored(vm.tintColor)
        actionView.titleLabel.accessibilityHint = "accessibility_button".localized
        actionView.actionImage.tintColor = vm.tintColor
        actionView.tintColor = .neutralWhite
    }

    override public func viewModelDidUpdate() {
        updateView()
    }

    // MARK: - Actions

    @objc public func onPressAction() {
        (viewModel as? CertificateCardViewModelProtocol)?.onClickAction()
    }

    @IBAction public func onFavoriteAction() {
        (viewModel as? CertificateCardViewModelProtocol)?.onClickFavorite()
    }
}
