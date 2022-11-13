//
//  AcousticFeedbackSettingsViewController.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassUI
import UIKit

class AcousticFeedbackSettingsViewController: UIViewController {
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var acousticFeedbackSwitch: LabeledSwitch!

    private var viewModel: AcousticFeedbackSettingsViewModelProtocol

    init(viewModel: AcousticFeedbackSettingsViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        title = viewModel.header
    }

    required init?(coder: NSCoder) {
        nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        setupDecriptionLabel()
        setupAcousticFeedbackSwitch()
    }

    private func setupView() {
        view.backgroundColor = .backgroundPrimary

        let backButton = UIBarButtonItem(image: .arrowBack, style: .done, target: self, action: #selector(backButtonTapped))
        backButton.accessibilityLabel = "accessibility_app_information_contact_label_back".localized // TODO change accessibility text when they are available
        navigationItem.leftBarButtonItem = backButton
        navigationController?.navigationBar.tintColor = .onBackground100
    }

    private func setupDecriptionLabel() {
        descriptionLabel.attributedText = viewModel.description.styledAs(.body)
        descriptionLabel.accessibilityTraits = .staticText
    }

    private func setupAcousticFeedbackSwitch() {
        acousticFeedbackSwitch.label.attributedText = viewModel
            .switchLabel
            .styledAs(.header_3)
            .colored(.onBackground110)
        acousticFeedbackSwitch.switchChanged = { [weak self] isOn in
            self?.viewModel.enableAcousticFeedback = isOn
        }
        acousticFeedbackSwitch.uiSwitch.isOn = viewModel.enableAcousticFeedback
        acousticFeedbackSwitch.updateAccessibility()
    }

    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
}
