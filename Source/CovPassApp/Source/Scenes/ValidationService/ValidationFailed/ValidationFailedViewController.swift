//
//  ValidationFailedViewController.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassUI
import UIKit

class ValidationFailedViewController: UIViewController {
    @IBOutlet var headerLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var hintView: HintView!
    @IBOutlet var acceptButton: MainButton!
    @IBOutlet var cancelButton: MainButton!

    private let viewModel: ValidationFailedViewModelProtocol

    @available(*, unavailable)
    required init?(coder _: NSCoder) { fatalError("init?(coder: NSCoder) not implemented yet") }

    init(viewModel: ValidationFailedViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: String(describing: Self.self), bundle: .main)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        headerLabel.attributedText = viewModel.title.styledAs(.header_1)
        descriptionLabel.attributedText = viewModel.description.styledAs(.body)
        acceptButton.style = .primary
        cancelButton.style = .primary
        acceptButton.title = viewModel.acceptButtonText
        cancelButton.title = viewModel.cancelButtonText
        acceptButton.action = {
            self.viewModel.continueProcess()
        }
        cancelButton.action = {
            self.viewModel.cancelProcess()
        }
        hintView.style = .info
        hintView.titleLabel.attributedText = viewModel.hintTitle.styledAs(.mainButton)
        hintView.bodyLabel.attributedText = viewModel.hintText
        hintView.setConstraintsToEdge()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        UIAccessibility.post(notification: .announcement, argument: ValidationServiceViewModel.Accessibility.openViewController.label)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIAccessibility.post(notification: .announcement, argument: ValidationServiceViewModel.Accessibility.closeViewController.label)
    }
}
