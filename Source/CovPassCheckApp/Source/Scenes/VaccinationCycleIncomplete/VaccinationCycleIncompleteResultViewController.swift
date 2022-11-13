//
//  VaccinationCycleIncompleteResultViewController.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassUI
import UIKit

final class VaccinationCycleIncompleteResultViewController: UIViewController {
    @IBOutlet var infoHeaderView: InfoHeaderView!
    @IBOutlet var headerStackView: UIStackView!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var subtitleLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var reasonStackview: UIStackView!
    @IBOutlet var linkLabel: LinkLabel!
    @IBOutlet var newScanButton: MainButton!
    @IBOutlet var counterLabel: UILabel!

    private var viewModel: VaccinationCycleIncompleteResultViewModelProtocol

    init(viewModel: VaccinationCycleIncompleteResultViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        self.viewModel.delegate = self
    }

    required init?(coder: NSCoder) { nil }

    override func viewDidLoad() {
        super.viewDidLoad()

        configureInfoHeaderView()
        configureImageView()
        configureLabels()
        configureButton()
        configureCounter()
        configureLink()
        configureReasonStackView()
        configureAccessibility()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIAccessibility.post(notification: .layoutChanged, argument: headerStackView)
    }

    private func configureInfoHeaderView() {
        infoHeaderView.attributedTitleText = nil
        infoHeaderView.action = viewModel.cancel
        infoHeaderView.image = .close
        infoHeaderView.actionButton.enableAccessibility(label: viewModel.closeButtonAccessibilityText,
                                                        traits: .button)
    }

    private func configureImageView() {
        imageView.image = .vaccinationCycleIncomplete
    }

    private func configureLabels() {
        titleLabel.attributedText = viewModel.title
            .styledAs(.header_24)
        subtitleLabel.attributedText = viewModel.subtitle
            .styledAs(.header_3)
            .colored(.onBackground80)
        descriptionLabel.attributedText = viewModel.description
            .styledAs(.body)
            .colored(.onBackground110)
        let titleSubTitleA11lText = viewModel.title + viewModel.subtitle
        headerStackView.enableAccessibility(label: titleSubTitleA11lText, traits: .header)
    }

    private func configureButton() {
        newScanButton.title = viewModel.buttonTitle
        newScanButton.action = viewModel.newScanPressed
    }

    private func configureCounter() {
        let countdownTimerModel = viewModel.countdownTimerModel
        let counterInfo = NSMutableAttributedString(
            attributedString: countdownTimerModel.counterInfo.styledAs(.body)
        )
        counterLabel.isHidden = countdownTimerModel.hideCountdown
        counterLabel.attributedText = counterInfo
        counterLabel.textAlignment = .center
    }

    private func configureReasonStackView() {
        reasonStackview.removeAllArrangedSubviews()
        for viewModel in viewModel.reasonViewModels {
            let paragraphView = ParagraphView()
            paragraphView.setup(with: viewModel)
            if #available(iOS 13.0, *) {
                paragraphView.accessibilityRespondsToUserInteraction = true
            }
            reasonStackview.addArrangedSubview(paragraphView)
        }
    }

    private func configureLink() {
        linkLabel.attributedText = NSMutableAttributedString(string: viewModel.faqLinkTitle)
            .replaceLink()
            .styledAs(.header_3)
            .colored(.brandAccent)
        linkLabel.linkCallback = { [weak self] url in
            self?.viewModel.openFAQ(url)
        }
    }
    
    private func configureAccessibility() {
        if #available(iOS 13.0, *) {
            headerStackView.accessibilityRespondsToUserInteraction = true
            descriptionLabel.accessibilityRespondsToUserInteraction = true
            counterLabel.accessibilityRespondsToUserInteraction = true
        }
    }
}

extension VaccinationCycleIncompleteResultViewController: ViewModelDelegate {
    func viewModelDidUpdate() {
        configureCounter()
    }

    func viewModelUpdateDidFailWithError(_: Error) {}
}

private extension ParagraphView {
    func setup(with viewModel: CertificateInvalidReasonViewModelProtocol) {
        layoutMargins.top = 0
        layoutMargins.bottom = 0
        imageView.tintColor = .brandAccent
        updateView(image: viewModel.icon,
                   title: viewModel.title.styledAs(.header_3),
                   body: viewModel.description.styledAs(.body).colored(.onBackground80))
        bottomBorder.isHidden = true
    }
}
