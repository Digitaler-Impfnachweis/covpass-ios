//
//  CertificateMaskImmunityCollectionViewCell.swift
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
    }
    enum Layout {
        static let cornerRadius: CGFloat = 26
        static let shadowRadius: CGFloat = 16
        static let shadowOpacity: CGFloat = 0.2
        static let shadowOffset: CGSize = .init(width: 0, height: -4)
    }
}

@IBDesignable
public class CertificateMaskImmunityCollectionViewCell: CardCollectionViewCell {
    // MARK: - IBOutlet

    @IBOutlet public var containerView: UIView!
    @IBOutlet public var contentStackView: UIStackView!
    @IBOutlet public var titleStackView: UIStackView!
    @IBOutlet public var titleLabel: UILabel!
    @IBOutlet public var qrContainerView: QRContainerMaskImmunityView!
    @IBOutlet public var gotoDetailButton: UIButton!
    @IBOutlet weak var redDotWrapper: UIView!
    @IBOutlet weak var redDotView: UIView!
    @IBOutlet weak var statusLabelWrapper: UIView!
    @IBOutlet weak var statusLabel: UILabel!
    
    // MARK: - Public Properties

    override public var viewModel: CardViewModel? {
        didSet {
            updateView()
        }
    }
    
    // MARK: - Lifecycle
    
    public func shadow(show: Bool) {
        clipsToBounds = !show
        contentView.clipsToBounds = !show
        contentView.layer.shadowColor = show ? UIColor.neutralBlack.cgColor : nil
        contentView.layer.shadowRadius = show ? Constants.Layout.shadowRadius : 3.0
        contentView.layer.shadowOpacity = show ? Float(Constants.Layout.shadowOpacity) : 0.0
        contentView.layer.shadowOffset = show ? Constants.Layout.shadowOffset : .init(width: 0, height: 0)
    }
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        shadow(show: true)
        containerView.tintColor = .brandAccent
        containerView.layer.cornerRadius = Constants.Layout.cornerRadius
        containerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onPressAction)))
        contentStackView.setCustomSpacing(.space_16, after: titleStackView)
        redDotView.drawRedDot()
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        contentView.layer.shadowPath = UIBezierPath(roundedRect: containerView.frame, cornerRadius: containerView.layer.cornerRadius).cgPath
    }

    private func updateView() {
        guard let vm = viewModel as? CertificateCardViewModelProtocol else { return }
        containerView.backgroundColor = vm.backgroundColor
        qrContainerView.image = vm.qrCode
        qrContainerView.maskStatusImage = vm.titleIcon
        qrContainerView.immunityStatusImage = vm.subtitleIcon
        qrContainerView.layoutMargins.bottom = .space_18
        qrContainerView.isHidden = vm.qrCode == nil
        qrContainerView.maskStatusText = vm.title
        qrContainerView.qrInfoText = Constants.qrInfoText
        qrContainerView.isInvalid = vm.isInvalid
        titleLabel.attributedText = vm.name.styledAs(.header_3).colored(vm.tintColor)
        titleLabel.lineBreakMode = .byTruncatingTail
        titleLabel.backgroundColor = .clear
        titleLabel.isHidden = false
        statusLabelWrapper.isHidden = !vm.showNotification
        redDotWrapper.isHidden = !vm.showNotification
        statusLabel.attributedText = vm.headerSubtitle?.styledAs(.label).colored(.neutralWhite)
        gotoDetailButton.tintColor = vm.tintColor
        gotoDetailButton.setImage(.chevronRight.withRenderingMode(.alwaysTemplate), for: .normal)
        let accessibilityText = "\(vm.name) \n \(vm.title) \n \(vm.subtitle) \n \(vm.headerSubtitle ?? "") \n \(Constants.qrInfoText)"
        enableAccessibility(label: accessibilityText, traits: .button)
    }

    override public func viewModelDidUpdate() {
        self.updateView()
    }

    // MARK: - Actions

    @IBAction @objc public func onPressAction() {
        (viewModel as? CertificateCardViewModelProtocol)?.onClickAction()
    }
}

private extension UIView {
    func drawRedDot() {
        backgroundColor = .statusRedDot
        layer.cornerRadius = 7
        layer.borderColor = UIColor.neutralWhite.cgColor
        layer.borderWidth = 1.5
    }
}
