//
//  CertificateItem.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import UIKit

public class CertificateItem: XibView {
    // MARK: - Properties

    @IBOutlet public var icon: UIImageView!
    @IBOutlet public var iconView: UIView!
    @IBOutlet public var titleLabel: PlainLabel!
    @IBOutlet public var subtitleLabel: PlainLabel!
    @IBOutlet public var infoLabel: PlainLabel!
    @IBOutlet public var info2Label: PlainLabel!
    @IBOutlet public var statusIcon: UIImageView!
    @IBOutlet public var activeView: UIView!
    @IBOutlet public var activeLabel: UILabel!
    @IBOutlet public var chevron: UIImageView!
    @IBOutlet var statusIconWrapper: UIView!
    @IBOutlet var statusIconLeadingConstraint: NSLayoutConstraint!
    @IBOutlet var statusIconTopConstraint: NSLayoutConstraint!
    @IBOutlet public var warningLabel: UILabel!
    @IBOutlet public var warningWrapper: UIView!

    private let action: (() -> Void)?
    private let hasAction: Bool
    public let viewModel: CertificateItemViewModel

    // MARK: - Lifecycle

    public init(viewModel: CertificateItemViewModel, action: (() -> Void)? = nil) {
        hasAction = action != nil
        self.viewModel = viewModel
        self.action = action
        super.init(frame: CGRect.zero)
        warningWrapper.isHidden = true
        setupView()
    }

    @available(*, unavailable)
    public required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public required init(frame _: CGRect) {
        fatalError("init(frame:) has not been implemented")
    }

    private func setupView() {
        icon.image = viewModel.icon.withRenderingMode(.alwaysTemplate)
        icon.tintColor = viewModel.iconColor
        iconView.backgroundColor = viewModel.iconBackgroundColor

        titleLabel.attributedText = viewModel.title.styledAs(.header_3)

        subtitleLabel.attributedText = viewModel.subtitle.styledAs(.body)

        infoLabel.attributedText = viewModel.info.styledAs(.body).colored(.onBackground70)

        let info2LabelTextStyle: TextStyle = viewModel.isNeutral ? .body : .header_3
        let info2LabelTextColor: UIColor = viewModel.isNeutral ? .onBackground70 : .onBackground100
        info2Label.attributedText = viewModel.info2?.styledAs(info2LabelTextStyle).colored(info2LabelTextColor).lineHeight(20)
        info2Label.isHidden = viewModel.info2 == nil

        statusIcon.image = viewModel.statusIcon
        statusIcon.isHidden = viewModel.statusIconHidden
        statusIconWrapper.isHidden = viewModel.statusIconHidden
        statusIconLeadingConstraint.constant = viewModel.statusIconHidden ? 0 : 4
        statusIconTopConstraint.constant = viewModel.statusIconHidden ? 0 : 5

        let activeLabelTextStyle: TextStyle = viewModel.isNeutral ? .header_3 : .body
        let activeLabelTextColor: UIColor = viewModel.isNeutral ? .onBackground100 : .onBackground70
        activeLabel.attributedText = viewModel.activeTitle?.styledAs(activeLabelTextStyle).colored(activeLabelTextColor)
        activeView.isHidden = viewModel.activeTitle == nil

        chevron.tintColor = .brandAccent

        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onPressItem)))

        warningLabel.attributedText = viewModel.warningText?.description.styledAs(.header_3)
        warningWrapper.isHidden = viewModel.warningText == nil

        setupAccessibility()
    }

    private func setupAccessibility() {
        isAccessibilityElement = true
        accessibilityTraits = hasAction ? .button : .staticText
        let buttonLabel = hasAction ? viewModel.certificateItemIsSelectableAccessibilityLabel : nil
        titleLabel.accessibilityLabel = viewModel.titleAccessibilityLabel
        subtitleLabel.accessibilityLabel = viewModel.subtitleAccessibilityLabel
        infoLabel.accessibilityLabel = viewModel.infoAccessibilityLabel
        info2Label.accessibilityLabel = viewModel.info2AccessibilityLabel
        statusIcon.accessibilityLabel = viewModel.statusIconAccessibilityLabel
        accessibilityLabel = [viewModel.titleAccessibilityLabel,
                              viewModel.subtitleAccessibilityLabel,
                              viewModel.infoAccessibilityLabel,
                              viewModel.info2AccessibilityLabel,
                              viewModel.statusIconAccessibilityLabel,
                              buttonLabel].compactMap { $0 }.joined(separator: ", ")
    }

    // MARK: - Methods

    @objc func onPressItem() {
        action?()
    }

    override public func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        super.didUpdateFocus(in: context, with: coordinator)
        updateFocusBorderView()
    }
}
