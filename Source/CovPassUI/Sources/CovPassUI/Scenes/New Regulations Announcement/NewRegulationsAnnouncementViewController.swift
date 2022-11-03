//
//  NewRegulationsAnnouncementViewController.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import UIKit

public class NewRegulationsAnnouncementViewController: UIViewController {

    @IBOutlet var infoHeaderView: InfoHeaderView!
    @IBOutlet var illustrationImageView: UIImageView!
    @IBOutlet var copyText1Label: UILabel!
    @IBOutlet var subtitleLabel: UILabel!
    @IBOutlet var copyText2Label: UILabel!
    @IBOutlet var button: MainButton!
    private let viewModel: NewRegulationsAnnouncementViewModelProtocol

    public init(viewModel: NewRegulationsAnnouncementViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: .uiBundle)
    }

    required init?(coder: NSCoder) { nil }

    public override func viewDidLoad() {
        super.viewDidLoad()
        setupInfoHeaderView()
        setupIllustration()
        setupLabels()
        setupButton()
        configureAccessibilityRespondsToUserInteraction()
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    private func setupInfoHeaderView() {
        infoHeaderView.attributedTitleText = viewModel.header
            .styledAs(.header_2)
        infoHeaderView.textLabel.enableAccessibility(label: viewModel.header, traits: .header)
        infoHeaderView.action = viewModel.close
        infoHeaderView.image = .close
        infoHeaderView.layoutMargins.bottom = .space_12
    }

    private func setupIllustration() {
        illustrationImageView.image = viewModel.illustration
        illustrationImageView.isAccessibilityElement = false
    }

    private func setupLabels() {
        let textColor = UIColor.onBackground110
        copyText1Label.attributedText = viewModel.copyText1
            .styledAs(.body)
            .colored(textColor)
        copyText1Label.enableAccessibility(label: viewModel.copyText1, traits: .staticText)
        copyText2Label.attributedText = viewModel.copyText2
            .styledAs(.body)
            .colored(textColor)
        copyText2Label.enableAccessibility(label: viewModel.copyText2, traits: .staticText)
        subtitleLabel.attributedText = viewModel.subtitle
            .styledAs(.header_3)
            .colored(textColor)
        subtitleLabel.enableAccessibility(label: viewModel.subtitle, traits: .staticText)
    }

    private func setupButton() {
        button.title = viewModel.buttonTitle
        button.action = viewModel.close
    }
    
    private func configureAccessibilityRespondsToUserInteraction() {
        if #available(iOS 13.0, *) {
            copyText1Label.accessibilityRespondsToUserInteraction = true
            subtitleLabel.accessibilityRespondsToUserInteraction = true
            copyText2Label.accessibilityRespondsToUserInteraction = true
        }
    }
}

extension NewRegulationsAnnouncementViewController: ModalInteractiveDismissibleProtocol {
    public func modalViewControllerDidDismiss() {
        viewModel.close()
    }
}
