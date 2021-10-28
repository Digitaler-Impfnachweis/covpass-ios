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

    private let action: () -> Void
    private let viewModel: CertificateItemViewModel

    // MARK: - Lifecycle

    public init(viewModel: CertificateItemViewModel, action: @escaping () -> Void) {
        self.viewModel = viewModel
        self.action = action
        super.init(frame: CGRect.zero)
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

        info2Label.attributedText = viewModel.info2?.styledAs(.header_3).lineHeight(20)
        info2Label.isHidden = viewModel.info2 == nil

        statusIcon.image = viewModel.statusIcon

        activeLabel.attributedText = viewModel.activeTitle?.styledAs(.body).colored(.onBackground70)
        activeView.isHidden = viewModel.activeTitle == nil

        chevron.tintColor = .brandAccent

        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onPressItem)))

        setupAccessibility()
    }

    private func setupAccessibility() {
        isAccessibilityElement = true
        accessibilityTraits = .button
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
                              viewModel.certificateItemIsSelectableAccessibilityLabel].compactMap { $0 }.joined(separator: ", ")
    }

    // MARK: - Methods

    @objc func onPressItem() {
        action()
    }
}
