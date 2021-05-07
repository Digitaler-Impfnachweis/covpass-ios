//
//  CertificateCollectionViewCell.swift
//  
//
//  Copyright © 2021 IBM. All rights reserved.
//

import Foundation
import UIKit
import VaccinationCommon

public typealias CertificateCardViewModelProtocol = CardViewModel & CertificateCardViewModelBase

public protocol CertificateCardViewModelBase {
    var title: String { get }
    var isFavorite: Bool { get }
    var qrCode: UIImage? { get }
    var name: String { get }
    var actionTitle: String { get }
    var actionImage: UIImage { get }
    var isLoading: Bool { get }
    var errorTitle: String? { get }
    var errorSubtitle: String? { get }
    var tintColor: UIColor { get }
    var isFullImmunization: Bool { get }
    var vaccinationDate: Date? { get }
    func onClickAction()
    func onClickFavorite()
}

@IBDesignable
public class CertificateCollectionViewCell: CardCollectionViewCell {
    // MARK: - IBOutlet

    @IBOutlet public var containerView: UIView!
    @IBOutlet public var contentStackView: UIStackView!
    @IBOutlet public var headerView: CardViewHeader!
    @IBOutlet public var actionView: CardViewAction!
    @IBOutlet public var loadingView: CardViewLoading!
    @IBOutlet public var titleView: PlainLabel!
    @IBOutlet public var QRContainerView: QRContainerView!

    // MARK: - Public Properties

    public override var viewModel: CardViewModel? {
        didSet {
            updateView()
        }
    }

    // MARK: - Private Properties

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
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        contentView.layer.shadowPath = UIBezierPath(roundedRect: containerView.frame, cornerRadius: containerView.layer.cornerRadius).cgPath
    }

    private func updateView() {
        guard let vm = viewModel as? CertificateCardViewModelProtocol else { return }

        containerView.backgroundColor = vm.backgroundColor

        headerView.action = vm.onClickFavorite
        headerView.subtitleLabel.attributedText = vm.title.styledAs(.body).colored(vm.tintColor)
        headerView.tintColor = vm.tintColor
        headerView.buttonImage = (vm.isFavorite ? UIImage.starFull : UIImage.starPartial).withRenderingMode(.alwaysTemplate)
        headerView.buttonTint = vm.tintColor
        contentStackView.setCustomSpacing(.space_12, after: headerView)

        QRContainerView.image = vm.qrCode
        QRContainerView.layoutMargins = .init(top: .space_20, left: .zero, bottom: .space_20, right: .zero)
        QRContainerView.isHidden = vm.qrCode == nil

        titleView.textableView.attributedText = vm.name.styledAs(.header_1).colored(vm.tintColor)
        titleView.backgroundColor = .clear
        contentStackView.setCustomSpacing(.space_12, after: titleView)

        actionView.stateImageView.image = vm.actionImage
        actionView.titleLabel.attributedText = vm.actionTitle.styledAs(.header_3).colored(vm.tintColor)
        actionView.stateImageView.tintColor = vm.tintColor
        actionView.actionButton.tintColor = vm.tintColor
        actionView.tintColor = .neutralWhite

        loadingView.isHidden = !vm.isLoading && vm.errorTitle == nil && vm.errorSubtitle == nil
        if !loadingView.isHidden {
            loadingView.layoutMargins = .init(top: .space_70, left: .space_24, bottom: .space_70, right: .space_24)
        }
        loadingView.titleLabel.isHidden = vm.errorTitle == nil
        loadingView.titleLabel.attributedText = vm.errorTitle?
            .styledAs(.header_3)
            .aligned(to: .center)
            .colored(.neutralWhite)
        loadingView.subtitleLabel.isHidden = vm.errorSubtitle == nil
        loadingView.subtitleLabel.attributedText = vm.errorSubtitle?
            .styledAs(.body)
            .aligned(to: .center)
            .colored(.neutralWhite)
    }

    // MARK: - Actions

    @objc public func onPressAction() {
        (viewModel as? CertificateCardViewModelProtocol)?.onClickAction()
    }
}
