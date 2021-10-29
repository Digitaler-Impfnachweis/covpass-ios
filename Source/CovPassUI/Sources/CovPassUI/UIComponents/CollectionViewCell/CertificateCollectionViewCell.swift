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
    static let qrInfoText = "certificates_start_screen_qr_code_app_reference_text".localized
    enum Accessibility {
        static let actionHint = "accessibility_button".localized
        static let favoriteActive = "accessibility_certificate_favorite_button_label_active".localized(bundle: .main)
        static let favoriteDeactive = "accessibility_certificate_favorite_button_label_not_active".localized(bundle: .main)
    }
    enum Layout {
        static let cornerRadius: CGFloat = 26
        static let shadowRadius: CGFloat = 16
        static let shadowOpacity: CGFloat = 0.2
        static let shadowOffset: CGSize = .init(width: 0, height: -4)
        static let titleLineHeight: CGFloat = 33
        static let actionLineHeight: CGFloat = 17
    }
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

    // MARK: - Lifecycle

    override public func awakeFromNib() {
        super.awakeFromNib()
        clipsToBounds = false

        contentView.clipsToBounds = false
        contentView.layer.shadowColor = UIColor.neutralBlack.cgColor
        contentView.layer.shadowRadius = Constants.Layout.shadowRadius
        contentView.layer.shadowOpacity = Float(Constants.Layout.shadowOpacity)
        contentView.layer.shadowOffset = Constants.Layout.shadowOffset

        containerView.tintColor = .brandAccent
        containerView.layer.cornerRadius = Constants.Layout.cornerRadius
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

        titleView.textableView.attributedText = vm.name.styledAs(.header_1).lineHeight(Constants.Layout.titleLineHeight).colored(vm.tintColor)
        titleView.backgroundColor = .clear
        favoriteButton.tintColor = vm.tintColor
        favoriteButton.setImage((vm.isFavorite ? UIImage.starFull : UIImage.starPartial).withRenderingMode(.alwaysTemplate), for: .normal)
        favoriteButton.isHidden = !vm.showFavorite
        let favoriteButtonAccessibilityText = vm.isFavorite ? Constants.Accessibility.favoriteActive : Constants.Accessibility.favoriteDeactive
        favoriteButton.enableAccessibility(label: favoriteButtonAccessibilityText, traits: .button)
        contentStackView.setCustomSpacing(.space_2, after: titleView)

        actionView.titleLabel.attributedText = vm.actionTitle.styledAs(.body).lineHeight(Constants.Layout.actionLineHeight).colored(vm.tintColor)
        actionView.enableAccessibility(label: vm.actionTitle, hint: Constants.Accessibility.actionHint, traits: .button)
        actionView.actionImage.tintColor = vm.tintColor
        actionView.tintColor = .neutralWhite
    }

    override public func viewModelDidUpdate() {
        DispatchQueue.main.async {
            self.updateView()
        }
    }

    // MARK: - Actions

    @objc public func onPressAction() {
        (viewModel as? CertificateCardViewModelProtocol)?.onClickAction()
    }

    @IBAction public func onFavoriteAction() {
        (viewModel as? CertificateCardViewModelProtocol)?.onClickFavorite()
    }
}
