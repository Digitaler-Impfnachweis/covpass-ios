//
//  MaskRequiredResultViewController.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassUI
import UIKit

final class MaskRequiredResultViewController: UIViewController {
    @IBOutlet var infoHeaderView: InfoHeaderView!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var headerStackView: UIStackView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var subtitleLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var reasonStackView: UIStackView!
    @IBOutlet var revocationInfoContainerView: UIView!
    @IBOutlet var revocationInfoView: HintView!
    @IBOutlet var rescanButton: MainButton!
    @IBOutlet var counterLabel: UILabel!
    @IBOutlet var stackViewLeadingConstraint: NSLayoutConstraint!
    
    private var viewModel: MaskRequiredResultViewModelProtocol
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
    
    init(viewModel: MaskRequiredResultViewModelProtocol) {
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
        configureReasonStackView()
        configureRevocationInfoView()
        configureButton()
        configureCounter()
        configureAccessibility()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIAccessibility.post(notification: .layoutChanged, argument: headerStackView)
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

    private func configureReasonStackView() {
        reasonStackView.removeAllArrangedSubviews()
        addSecondCertificateReasonIfNotHidden()
        for viewModel in viewModel.reasonViewModels {
            let paragraphView = ParagraphView()
            paragraphView.setup(with: viewModel)
            if #available(iOS 13.0, *) {
                paragraphView.accessibilityRespondsToUserInteraction = true
            }
            reasonStackView.addArrangedSubview(paragraphView)
        }
    }

    private func addSecondCertificateReasonIfNotHidden() {
        if !viewModel.secondCertificateHintHidden {
            let viewModel = viewModel.secondCertificateReasonViewModel
            let view = ButtonBox()
            
            view.paragraphView.setup(with: viewModel)
            view.button.title = viewModel.buttonText
            view.button.action = self.viewModel.scanSecondCertificate
            stackViewLeadingConstraint.constant = 24.0

            reasonStackView.addArrangedSubview(view)
        }
    }

    private func configureButton() {
        rescanButton.title = viewModel.buttonTitle
        rescanButton.action = viewModel.rescan
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
    
    private func configureAccessibility() {
        if #available(iOS 13.0, *) {
            headerStackView.accessibilityRespondsToUserInteraction = true
            descriptionLabel.accessibilityRespondsToUserInteraction = true
            revocationInfoContainerView.accessibilityRespondsToUserInteraction = true
            counterLabel.accessibilityRespondsToUserInteraction = true
        }
    }
}

extension MaskRequiredResultViewController: ViewModelDelegate {
    func viewModelDidUpdate() {
        configureCounter()
    }

    func viewModelUpdateDidFailWithError(_: Error) {}
}

private extension ParagraphView {
    func setup(with viewModel: MaskRequiredReasonViewModelProtocol) {
        layoutMargins.top = 0
        layoutMargins.bottom = 0
        updateView(image: viewModel.icon,
                   title: viewModel.title.styledAs(.header_3),
                   body: viewModel.description.styledAs(.body).colored(.onBackground80))
        bottomBorder.isHidden = true
    }
}
