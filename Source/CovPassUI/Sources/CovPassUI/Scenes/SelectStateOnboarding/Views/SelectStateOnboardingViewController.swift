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

    // MARK: - Methods

    private func configureView() {
        decorativeImageView.image = viewModel.image
        decorativeImageView.backgroundColor = .backgroundPrimary
        button.style = .primary
        button.title = "ok".localized(bundle: .main)
        headerView.attributedTitleText = viewModel.title.styledAs(.header_1)
        headerView.image = .close
        headerView.action = viewModel.close
        button.action = viewModel.close
        copyLabel.attributedText = viewModel.copyText.styledAs(.body)
        copyLabel.layoutMargins = .init(top: .space_24, left: .space_24, bottom: .space_12, right: .space_24)
        copy2Label.attributedText = viewModel.copy2Text.styledAs(.body)
        copy2Label.layoutMargins = .init(top: .space_24, left: .space_24, bottom: .space_24, right: .space_24)
    }

    private func configureInputView() {
        stateSelection.titleLabel.attributedText = viewModel.inputTitle.styledAs(.label)
        stateSelection.valueLabel.attributedText = viewModel.inputValue.styledAs(.body)
        stateSelection.iconView.image = .map
        stateSelection.iconView.tintColor = .brandBase
        stateSelection.backgroundColor = .white
        stateSelection.onClickAction = { [weak self] in
            self?.viewModel
                .showFederalStateSelection()
                .done {
                    self?.stateSelection.valueLabel.text = self?.viewModel.inputValue
                }
                .cauterize()
        }
    }
}
