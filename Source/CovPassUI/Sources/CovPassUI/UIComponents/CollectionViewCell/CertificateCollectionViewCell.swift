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
    enum Layout {
        static let cornerRadius: CGFloat = 26
        static let shadowRadius: CGFloat = 16
        static let shadowOpacity: CGFloat = 0.2
        static let shadowOffset: CGSize = .init(width: 0, height: -4)
    }
}

public typealias CertificateCardViewModelProtocol = CardViewModel & CertificateCardViewModelBase

public protocol CertificateCardViewModelBase {
    var title: String { get }
    var subtitle: String { get }
    var headerSubtitle: String? { get }
    var titleIcon: UIImage { get }
    var subtitleIcon: UIImage { get }
    var isInvalid: Bool { get }
    var qrCode: UIImage? { get }
    var name: String { get }
    var tintColor: UIColor { get }
    var delegate: ViewModelDelegate? { get set }
    var maskRulesNotAvailable: Bool { get set }
    var regionText: String? { get }
    func onClickAction()
}

@IBDesignable
public class CertificateCollectionViewCell: CardCollectionViewCell {
    // MARK: - IBOutlet

    @IBOutlet public var containerView: UIView!
    @IBOutlet public var contentStackView: UIStackView!
    @IBOutlet public var titleStackView: UIStackView!
    @IBOutlet public var titleView: UILabel!
    @IBOutlet public var qrContainerView: QRContainerView!

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
        qrContainerView.title = vm.title
        qrContainerView.titleColorValue = vm.textColor
        qrContainerView.subtitle = vm.subtitle
        qrContainerView.subtitleColorValue = vm.textColor
        qrContainerView.qrInfoText = Constants.qrInfoText
        qrContainerView.isInvalid = vm.isInvalid
        titleView.attributedText = vm.name.styledAs(.header_3).colored(vm.tintColor)
        titleView.lineBreakMode = .byTruncatingTail
        titleView.backgroundColor = .clear
        titleView.isHidden = true
        var accessibilityText = "\(vm.name) \n \(vm.title) \n \(vm.subtitle) \n \(vm.headerSubtitle ?? "")"
        if !vm.isInvalid {
            accessibilityText.append(" \n \(Constants.qrInfoText)")
        }
        contentView.enableAccessibility(label: accessibilityText, traits: .button)

    }

    override public func viewModelDidUpdate() {
        DispatchQueue.main.async {
            self.updateView()
        }
    }
    
    public override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        super.didUpdateFocus(in: context, with: coordinator)
        contentView.updateFocusBorderView()
    }

    // MARK: - Actions

    @objc public func onPressAction() {
        (viewModel as? CertificateCardViewModelProtocol)?.onClickAction()
    }
}
