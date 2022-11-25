//
//  FederalStateSettingsViewController.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import UIKit

open class FederalStateSettingsViewController: UIViewController {
    // MARK: - Properties

    @IBOutlet var copy1Label: PlainLabel!
    @IBOutlet var copy2Label: PlainLabel!
    @IBOutlet var stateSelection: InputView!

    let viewModel: FederalStateSettingsViewModelProtocol

    // MARK: - Lifecycle

    public init(viewModel: FederalStateSettingsViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: String(describing: Self.self), bundle: .module)
        title = viewModel.title
    }

    @available(*, unavailable)
    public required init?(coder _: NSCoder) { fatalError("init?(coder: NSCoder) not implemented yet") }

    override public func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .backgroundPrimary

        let backButton = UIBarButtonItem(image: .arrowBack, style: .done, target: self, action: #selector(backButtonTapped))
        backButton.accessibilityLabel = "accessibility_app_information_contact_label_back".localized // TODO change accessibility text when they are available
        navigationItem.leftBarButtonItem = backButton
        navigationController?.navigationBar.tintColor = .onBackground100
        
        configureCopy()
        configureInputView()
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIAccessibility.post(notification: .layoutChanged, argument: viewModel.openingAnnounce)
    }
    
    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        UIAccessibility.post(notification: .layoutChanged, argument: viewModel.closingAnnounce)
    }

    // MARK: - Methods

    private func configureCopy() {
        copy1Label.attributedText = viewModel.copy1Text.styledAs(.body)
        copy1Label.layoutMargins = .init(top: .space_24, left: .space_24, bottom: .space_24, right: .space_24)
        copy2Label.attributedText = viewModel.copy2Text?.styledAs(.body).colored(.greyDark)
        copy2Label.layoutMargins = .init(top: .space_8, left: .space_24, bottom: .space_24, right: .space_24)
        copy2Label.backgroundColor = .neutralWhite
        copy2Label.isHidden = viewModel.copy2Text == nil
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
                    UIAccessibility.post(notification: .layoutChanged, argument: self?.viewModel.choosenState)
                    self?.stateSelection.valueLabel.text = self?.viewModel.inputValue
                    self?.configureCopy()
                }
                .cauterize()
        }
        stateSelection.enableAccessibility(label: viewModel.inputTitle,
                                           value: viewModel.inputValue,
                                           traits: .button)
    }

    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
}
