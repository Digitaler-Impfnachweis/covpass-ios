//
//  ScanCountWarningViewController.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import CovPassUI
import UIKit


class ScanCountWarningViewController: UIViewController {
    
    @IBOutlet weak var headerImageView: UIImageView!
    @IBOutlet weak var descriptionView: HintView!
    @IBOutlet weak var acceptButton: MainButton!
    @IBOutlet weak var cancelButton: MainButton!
    
    private let viewModel: ScanCountWarningViewModelProtocol
    
    @available(*, unavailable)
    required init?(coder _: NSCoder) { fatalError("init?(coder: NSCoder) not implemented yet") }
    
    init(viewModel: ScanCountWarningViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: String(describing: Self.self), bundle: .main)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIAccessibility.post(notification: .announcement, argument: ValidationServiceViewModel.Accessibility.openViewController.label)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIAccessibility.post(notification: .announcement, argument: ValidationServiceViewModel.Accessibility.closeViewController.label)
    }
    
    private func configureView() {
        navigationController?.setNavigationBarHidden(true, animated: true)
        configureHeaderImageView()
        configureDescriptionView()
        configureAcceptButton()
        configureCancelButton()
        configureButtonActions()
    }
    
    private func configureHeaderImageView() {
        headerImageView.image = viewModel.headerImage
        headerImageView.enableAccessibility(label: viewModel.accImageDescription)
        headerImageView.pinHeightToScaleAspectFit()
    }
    
    private func configureDescriptionView() {
        descriptionView.iconView.image = nil
        descriptionView.containerView.backgroundColor = .clear
        descriptionView.containerView?.layer.borderWidth = 0.0
        descriptionView.containerView?.layer.borderColor = UIColor.clear.cgColor
        descriptionView.containerView?.layer.cornerRadius = 0.0
        descriptionView.containerLeadingConstraint.constant = 10
        descriptionView.containerTrailingConstraint.constant = 10
        descriptionView.containerTopConstraint.constant = 0
        descriptionView.containerBottomConstraint.constant = 0
        descriptionView.titleLabel.attributedText = viewModel.title.styledAs(.header_1)
        descriptionView.bodyLabel.attributedText = viewModel.description.styledAs(.body)
    }
    
    private func configureAcceptButton() {
        acceptButton.style = .primary
        acceptButton.title = viewModel.acceptButtonText
    }
    
    private func configureCancelButton() {
        cancelButton.style = .plain
        cancelButton.title = viewModel.cancelButtonText
    }
    
    private func configureButtonActions() {
        acceptButton.action = {
            self.viewModel.continueProcess()
        }
        cancelButton.action = {
            self.viewModel.cancelProcess()
        }
        descriptionView.bodyLabel.linkCallback  = { [weak self] url in
            self?.viewModel.routeToSafari(url: url)
        }
    }

}

