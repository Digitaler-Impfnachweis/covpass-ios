//
//  DifferentPersonViewController.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassUI
import Foundation
import UIKit

class DifferentPersonViewController: UIViewController {
    // MARK: - Properties

    @IBOutlet var headline: InfoHeaderView!
    @IBOutlet var subtitleLabel: UILabel!
    @IBOutlet var firstResultHeadlineLabel: UILabel!
    @IBOutlet var firstResultCard: CertResultCard!
    @IBOutlet var secondResultHeadlineLabel: UILabel!
    @IBOutlet var secondResultCard: CertResultCard!
    @IBOutlet var footerHeadline: UILabel!
    @IBOutlet var footerText: UILabel!
    @IBOutlet var footerLink: UILabel!
    @IBOutlet var startOverButton: MainButton!
    @IBOutlet var footerStack: UIStackView!
    @IBOutlet var counterLabel: UILabel!

    private(set) var viewModel: DifferentPersonViewModelProtocol

    // MARK: - Lifecycle

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init?(coder: NSCoder) not implemented yet")
    }

    init(viewModel: DifferentPersonViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: String(describing: Self.self), bundle: .main)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.delegate = self
        configureView()
    }

    private func configureView() {
        configureHeadline()
        configureButtons()
        configureContent()
        configureCounter()
    }

    private func configureHeadline() {
        headline.attributedTitleText = viewModel.title.styledAs(.header_1)
        headline.action = viewModel.ignoreButton
        headline.image = .close
    }

    private func configureButtons() {
        startOverButton.style = .alternative
        startOverButton.title = viewModel.startOverButton
        startOverButton.action = {
            self.viewModel.startover()
        }
    }

    private func configureContent() {
        subtitleLabel.attributedText = viewModel.subtitle.styledAs(.body)
        footerHeadline.attributedText = viewModel.footerHeadline.styledAs(.header_3)
        footerText.attributedText = viewModel.footerText.styledAs(.body)
        footerLink.attributedText = viewModel.footerLinkText.styledAs(.header_3).colored(.brandAccent)

        firstResultHeadlineLabel.attributedText = viewModel.firstResultTitle.styledAs(.subheader_2)
        firstResultCard.resultImage = viewModel.firstResultCardImage
        firstResultCard.title = viewModel.firstResultName.styledAs(.header_2)
        firstResultCard.subtitle = viewModel.firstResultNameTranslittered.styledAs(.subheader_2)
        firstResultCard.linkImage = nil
        firstResultCard.bottomText = viewModel.firstResultDateOfBirth.styledAs(.body)

        secondResultHeadlineLabel.attributedText = viewModel.secondResultTitle.styledAs(.subheader_2)
        secondResultCard.resultImage = viewModel.SecondResultCardImage
        secondResultCard.title = viewModel.secondResultName.styledAs(.header_2)
        secondResultCard.subtitle = viewModel.secondResultNameTranslittered.styledAs(.subheader_2)
        secondResultCard.linkImage = nil
        secondResultCard.bottomText = viewModel.secondResultDateOfBirth.styledAs(.body)
        secondResultCard.contentView?.backgroundColor = .resultYellowBackground
        secondResultCard.contentView?.layer.borderColor = UIColor.resultYellow.cgColor
        secondResultCard.contentView?.layer.borderWidth = 2
    }

    @IBAction func footerLinkTapped(_: Any) {
        viewModel.ignoreButton()
    }

    private func configureCounter() {
        let counterInfo: NSMutableAttributedString = .init(
            attributedString: viewModel.countdownTimerModel.counterInfo.styledAs(.body)
        )
        counterLabel.attributedText = counterInfo
        counterLabel.textAlignment = .center
        counterLabel.isHidden = viewModel.countdownTimerModel.hideCountdown
    }

    private func dismissIfCountdownIsFinished() {
        if viewModel.countdownTimerModel.shouldDismiss {
            viewModel.ignoreButton()
        }
    }
}

extension DifferentPersonViewController: ViewModelDelegate {
    func viewModelDidUpdate() {
        configureContent()
        configureCounter()
        dismissIfCountdownIsFinished()
    }

    func viewModelUpdateDidFailWithError(_: Error) {}
}
