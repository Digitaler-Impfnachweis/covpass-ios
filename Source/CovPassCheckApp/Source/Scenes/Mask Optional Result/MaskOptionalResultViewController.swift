//
//  MaskOptionalResultViewController.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassUI
import UIKit

final class MaskOptionalResultViewController: UIViewController {
    @IBOutlet var infoHeaderView: InfoHeaderView!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var subtitleLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var holderInformationContainerView: UIView!
    @IBOutlet var holderInformationView: ParagraphView!
    @IBOutlet var revocationInfoContainerView: UIView!
    @IBOutlet var revocationInfoView: HintView!
    @IBOutlet var rescanButton: MainButton!
    @IBOutlet var counterLabel: UILabel!

    private var viewModel: MaskOptionalResultViewModelProtocol
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

    init(viewModel: MaskOptionalResultViewModelProtocol) {
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
        configureHolderInformationView()
        configureRevocationInfoView()
        configureButton()
        configureCounter()
    }

    private func configureInfoHeaderView() {
        infoHeaderView.attributedTitleText = nil
        infoHeaderView.action = viewModel.cancel
        infoHeaderView.image = .close
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
    }

    private func configureHolderInformationView() {
        holderInformationView.imageViewWidthConstraint.constant = 32
        holderInformationView.image = .cardCircle
        holderInformationView.bottomBorder.isHidden = true
        holderInformationView.attributedTitleText = viewModel.holderName
            .styledAs(.header_2)
        holderInformationView.attributedSubtitleText = viewModel.holderNameTransliterated
            .styledAs(.header_3)
            .colored(.onBackground80)
        holderInformationView.attributedBodyText = viewModel.holderBirthday
            .styledAs(.body)
        holderInformationView.backgroundColor = .clear
        holderInformationContainerView.backgroundColor = .backgroundSecondary20
    }

    private func configureRevocationInfoView() {
        revocationInfoView.style = .info
        revocationInfoContainerView.isHidden = viewModel.revocationInfoHidden
        let bodyLabel = NSMutableAttributedString(
            attributedString: viewModel.revocationInfoText
                .appending("\n\n")
                .styledAs(.body)
                .colored(.onBackground70)
        )
        bodyLabel.append(revocationLink)
        revocationInfoView.bodyLabel.attributedText = bodyLabel
        revocationInfoView.bodyLabel.linkCallback = viewModel.revoke
        revocationInfoView.titleLabel.attributedText = viewModel.revocationHeadline
            .styledAs(.mainButton)
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
}

extension MaskOptionalResultViewController: ViewModelDelegate {
    func viewModelDidUpdate() {
        configureCounter()
    }

    func viewModelUpdateDidFailWithError(_: Error) {}
}
