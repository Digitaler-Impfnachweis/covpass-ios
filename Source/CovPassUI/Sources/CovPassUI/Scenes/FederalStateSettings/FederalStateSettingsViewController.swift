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

    @IBOutlet var copyLabel: PlainLabel!
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
        copyLabel.attributedText = viewModel.copyText.styledAs(.body)
        copyLabel.layoutMargins = .init(top: .space_24, left: .space_24, bottom: .space_24, right: .space_24)
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
                }
                .cauterize()
        }
        stateSelection.enableAccessibility(label: viewModel.inputTitle,
                                           value: viewModel.inputValue,
                                           traits: .button)
    }
}
