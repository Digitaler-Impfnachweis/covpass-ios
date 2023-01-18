//
//  CertificateInvalidResultViewController.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassUI
import UIKit

final class CertificateInvalidResultViewController: UIViewController {
    @IBOutlet var infoHeaderView: InfoHeaderView!
    @IBOutlet var headerStackView: UIStackView!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var subtitleLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var revocationInfoContainerView: UIView!
    @IBOutlet var revocationInfoView: HintView!
    @IBOutlet var retryButton: MainButton!
    @IBOutlet var startOverButton: MainButton!
    @IBOutlet var reasonStackview: UIStackView!
    @IBOutlet var counterLabel: UILabel!
    @IBOutlet var travelRulesLinkLabel: LinkLabel!
    @IBOutlet var bottomStackView: UIStackView!
    @IBOutlet var scrollView: UIScrollView!

    private var viewModel: CertificateInvalidResultViewModelProtocol
    private lazy var revocationLink: NSAttributedString = {
        let linkText = (viewModel.revocationLinkTitle + " ⟩")
            .styledAs(.header_3)
            .colored(.brandAccent)
        let string = NSMutableAttributedString(attributedString: linkText)
        string.addAttribute(
            .link,
            value: "",
            range: NSMakeRange(0, string.length)
        )
        return string
    }()

    init(viewModel: CertificateInvalidResultViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        self.viewModel.delegate = self
    }

    required init?(coder _: NSCoder) { nil }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureInfoHeaderView()
        configureImageView()
        configureLabels()
        configureReasonStackView()
        configureRevocationInfoView()
        configureButton()
        configureCounter()
        configureAccessibility()
        setupGradientBottomView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIAccessibility.post(notification: .layoutChanged, argument: headerStackView)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.startCountdown()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel.stopCountdown()
    }

    private func configureInfoHeaderView() {
        infoHeaderView.attributedTitleText = nil
        infoHeaderView.action = viewModel.cancel
        infoHeaderView.image = .close
        infoHeaderView.actionButton.enableAccessibility(label: viewModel.closeButtonAccessibilityText,
                                                        traits: .button)
    }

    private func configureImageView() {
        imageView.image = viewModel.image
    }

    private func configureLabels() {
        titleLabel.attributedText = viewModel.title
            .styledAs(.header_1)
        subtitleLabel.attributedText = viewModel.subtitle
            .styledAs(.header_3)
            .colored(.onBackground80)
        descriptionLabel.attributedText = viewModel.description
            .styledAs(.body)
            .colored(.onBackground110)
        let titleSubTitleA11lText = viewModel.title + viewModel.subtitle
        headerStackView.enableAccessibility(label: titleSubTitleA11lText, traits: .header)
        travelRulesLinkLabel.attributedText = viewModel.travelRules.styledAs(.header_3)
        travelRulesLinkLabel.isHidden = viewModel.travelRulesIsHidden
        travelRulesLinkLabel.layoutMargins = .init(top: 8, left: 18, bottom: 0, right: 18)
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

    private func configureRevocationInfoView() {
        revocationInfoView.style = .info
        revocationInfoContainerView.isHidden = viewModel.revocationInfoHidden
        let bodyLabel = viewModel.revocationInfoText.styledAs(.body).colored(.onBackground70)
        revocationInfoView.bodyLabel.attributedText = bodyLabel
        revocationInfoView.bodyLabel.additionalAttributedText = revocationLink
        revocationInfoView.bodyLabel.linkCallback = viewModel.revoke
        revocationInfoView.titleLabel.attributedText = viewModel.revocationHeadline
            .styledAs(.mainButton)
    }

    private func configureButton() {
        startOverButton.title = viewModel.startOverButtonTitle
        startOverButton.action = viewModel.startOver
        startOverButton.style = .alternative
        retryButton.title = viewModel.retryButtonTitle
        retryButton.action = viewModel.retry
        retryButton.style = .primary
        retryButton.isHidden = viewModel.rescanIsHidden
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

    private func setupGradientBottomView() {
        bottomStackView.layoutIfNeeded()
        scrollView.contentInset.bottom = bottomStackView.bounds.height
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bottomStackView.bounds
        gradientLayer.colors = [UIColor(white: 1, alpha: 0).cgColor, UIColor.backgroundPrimary.cgColor, UIColor.backgroundPrimary.cgColor]
        bottomStackView.layer.insertSublayer(gradientLayer, at: 0)
    }

    private func configureAccessibility() {
        if #available(iOS 13.0, *) {
            headerStackView.accessibilityRespondsToUserInteraction = true
            descriptionLabel.accessibilityRespondsToUserInteraction = true
            reasonStackview.accessibilityRespondsToUserInteraction = true
            revocationInfoContainerView.accessibilityRespondsToUserInteraction = true
            counterLabel.accessibilityRespondsToUserInteraction = true
        }
    }
}

extension CertificateInvalidResultViewController: ViewModelDelegate {
    func viewModelDidUpdate() {
        configureCounter()
    }

    func viewModelUpdateDidFailWithError(_: Error) {}
}

private extension ParagraphView {
    func setup(with viewModel: CertificateInvalidReasonViewModelProtocol) {
        layoutMargins.top = 0
        layoutMargins.bottom = 0
        updateView(image: viewModel.icon,
                   title: viewModel.title.styledAs(.header_3),
                   body: viewModel.description.styledAs(.body).colored(.onBackground80))
        bottomBorder.isHidden = true
    }
}
