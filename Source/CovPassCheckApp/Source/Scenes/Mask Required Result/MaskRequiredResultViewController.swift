//
//  MaskRequiredResultViewController.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassUI
import UIKit

final class MaskRequiredResultViewController: UIViewController {
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var subtitleLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var reasonStackView: UIStackView!
    @IBOutlet var rescanButton: MainButton!
    @IBOutlet var counterLabel: UILabel!

    private var viewModel: MaskRequiredResultViewModelProtocol

    init(viewModel: MaskRequiredResultViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        self.viewModel.delegate = self
    }

    required init?(coder: NSCoder) { nil }

    override func viewDidLoad() {
        super.viewDidLoad()

        configureImageView()
        configureLabels()
        configureReasonStackView()
        configureButton()
        configureCounter()
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

    private func configureReasonStackView() {
        reasonStackView.removeAllArrangedSubviews()
        for viewModel in viewModel.reasonViewModels {
            let paragraphView = ParagraphView()
            paragraphView.setup(with: viewModel)
            reasonStackView.addArrangedSubview(paragraphView)
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
        attributedTitleText = viewModel
            .title
            .styledAs(.header_3)
        attributedBodyText = viewModel
            .description
            .styledAs(.body)
            .colored(.onBackground80)
        image = viewModel.icon
        bottomBorder.isHidden = true
    }
}
