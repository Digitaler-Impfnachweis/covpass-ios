//
//  SelectStateOnboardingViewController.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import UIKit

open class SelectStateOnboardingViewController: UIViewController {
    // MARK: - Properties

    @IBOutlet var headerView: InfoHeaderView!
    @IBOutlet var decorativeImageView: UIImageView!
    @IBOutlet var copyLabel: PlainLabel!
    @IBOutlet var stateSelection: InputView!
    @IBOutlet var copy2Label: PlainLabel!
    @IBOutlet var copy3Label: PlainLabel!
    @IBOutlet var button: MainButton!

    let viewModel: SelectStateOnboardingViewModelProtocol

    // MARK: - Lifecycle

    public init(viewModel: SelectStateOnboardingViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: String(describing: Self.self), bundle: .module)
        title = viewModel.title
    }

    @available(*, unavailable)
    public required init?(coder _: NSCoder) { fatalError("init?(coder: NSCoder) not implemented yet") }

    override public func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .neutralWhite
        configureView()
        configureInputView()
    }

    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIAccessibility.post(notification: .layoutChanged, argument: viewModel.openingAnnounce)
    }

    override open func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        UIAccessibility.post(notification: .layoutChanged, argument: viewModel.closingAnnounce)
    }

    override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        configureView()
    }

    // MARK: - Methods

    private func configureView() {
        decorativeImageView.image = viewModel.image
        decorativeImageView.backgroundColor = .backgroundPrimary
        decorativeImageView.isAccessibilityElement = false
        decorativeImageView.isHidden = UIScreen.isLandscape
        button.style = .primary
        button.title = "ok".localized(bundle: .main)
        headerView.attributedTitleText = viewModel.title.styledAs(.header_1)
        headerView.image = .close
        headerView.textLabel.enableAccessibility(label: viewModel.title, traits: .header)
        headerView.action = viewModel.close
        button.action = viewModel.close
        copyLabel.attributedText = viewModel.copyText.styledAs(.body)
        copyLabel.layoutMargins = .init(top: .space_24, left: .space_24, bottom: .space_12, right: .space_24)
        copy2Label.attributedText = viewModel.copy2Text.styledAs(.body)
        copy2Label.layoutMargins = .init(top: .space_24, left: .space_24, bottom: .space_24, right: .space_24)
        copy3Label.attributedText = viewModel.copy3Text?.styledAs(.body).colored(.darkGray)
        copy3Label.layoutMargins = .init(top: .space_8, left: .space_24, bottom: .space_24, right: .space_24)
        copy3Label.isHidden = viewModel.copy3Text == nil
    }

    private func configureInputView() {
        stateSelection.titleLabel.attributedText = viewModel.inputTitle.styledAs(.label)
        stateSelection.valueLabel.attributedText = viewModel.inputValue.styledAs(.body)
        stateSelection.enableAccessibility(label: viewModel.inputTitle,
                                           value: viewModel.inputValue,
                                           traits: .button)
        stateSelection.iconView.image = .map
        stateSelection.iconView.tintColor = .brandBase
        stateSelection.backgroundColor = .white
        stateSelection.onClickAction = { [weak self] in
            self?.viewModel
                .showFederalStateSelection()
                .done {
                    UIAccessibility.post(notification: .layoutChanged, argument: self?.viewModel.choosenState)
                    self?.stateSelection.valueLabel.text = self?.viewModel.inputValue
                }
                .cauterize()
        }
    }

    private func configureAccessibilityRespondsToUserInteraction() {
        if #available(iOS 13.0, *) {
            copyLabel.accessibilityRespondsToUserInteraction = true
            stateSelection.accessibilityRespondsToUserInteraction = true
            copy2Label.accessibilityRespondsToUserInteraction = true
        }
    }
}
