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
    @IBOutlet var thirdResultHeadlineLabel: UILabel!
    @IBOutlet var thirdResultCard: CertResultCard!
    @IBOutlet var ignoreView: ParagraphView!
    @IBOutlet var rescanButton: MainButton!
    @IBOutlet var cancelButton: MainButton!
    @IBOutlet var ignoreStackView: UIStackView!
    @IBOutlet var thirdResultStackView: UIStackView!
    @IBOutlet var bottomStackView: UIStackView!
    @IBOutlet var counterLabel: UILabel!
    @IBOutlet var scrollView: UIScrollView!
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
        view.backgroundColor = .neutralWhite
        configureView()
        setupGradientBottomView()
    }

    private func configureView() {
        configureHeadline()
        configureButtons()
        configureContent()
        configureCounter()
    }

    private func configureHeadline() {
        headline.attributedTitleText = viewModel.title.styledAs(.header_2)
        headline.action = viewModel.close
        headline.image = .close
    }

    private func configureButtons() {
        rescanButton.style = .primary
        rescanButton.title = viewModel.rescanButtonTitle
        rescanButton.action = viewModel.rescan
        cancelButton.style = .alternative
        cancelButton.title = viewModel.cancelButtonTitle
        cancelButton.action = viewModel.close
    }

    private func configureIgnoreView() {
        ignoreStackView.isHidden = viewModel.ignoringIsHidden
        let titleText = viewModel.footerHeadline.styledAs(.header_3)
        let subtitleText = viewModel.footerText.styledAs(.body)
        let footerButtonText = viewModel.footerLinkText
            .styledAs(.header_3)
            .colored(.brandAccent)
            .underlined()

        ignoreView.updateView(title: titleText,
                              subtitle: subtitleText,
                              secondBody: footerButtonText)
        ignoreStackView.isHidden = viewModel.ignoringIsHidden
        ignoreView.bottomBorder.isHidden = true
    }

    private func configureFirstCard() {
        firstResultHeadlineLabel.attributedText = viewModel.firstResultTitle
            .styledAs(.header_3)
            .colored(.onBackground80)
        firstResultCard.title = viewModel.firstResultName
            .styledAs(.header_2)
            .colored(.onBackground110)
        firstResultCard.subtitle = viewModel.firstResultNameTranslittered
            .styledAs(.subheader_2)
            .colored(.onBackground80)
        firstResultCard.bottomText = viewModel.firstResultDateOfBirth
            .styledAs(.body)
            .colored(.onBackground110)
        firstResultCard.resultImage = viewModel.firstResultCardImage
        firstResultCard.linkImage = nil
        firstResultCard?.contentView?.backgroundColor = .brandAccent20
    }

    private func configureSecondCard() {
        secondResultHeadlineLabel.attributedText = viewModel.secondResultTitle
            .styledAs(.header_3)
            .colored(.onBackground80)
        secondResultCard.title = viewModel.secondResultName
            .styledAs(.header_2)
            .colored(.onBackground110)
        secondResultCard.subtitle = viewModel.secondResultNameTranslittered
            .styledAs(.subheader_2)
            .colored(.onBackground80)
        secondResultCard.bottomText = viewModel.secondResultDateOfBirth
            .styledAs(.body)
            .colored(.onBackground110)
        secondResultCard.resultImage = viewModel.secondResultCardImage
        secondResultCard.linkImage = nil
        secondResultCard?.contentView?.backgroundColor = .brandAccent20
    }

    private func configureThirdCard() {
        thirdResultHeadlineLabel.attributedText = viewModel.thirdResultTitle
            .styledAs(.header_3)
            .colored(.onBackground80)
        thirdResultCard.title = viewModel.thirdResultName?
            .styledAs(.header_2)
            .colored(.onBackground110)
        thirdResultCard.subtitle = viewModel.thirdResultNameTranslittered?
            .styledAs(.subheader_2)
            .colored(.onBackground80)
        thirdResultCard.bottomText = viewModel.thirdResultDateOfBirth?
            .styledAs(.body)
            .colored(.onBackground110)
        thirdResultStackView.isHidden = viewModel.thirdCardIsHidden
        thirdResultCard.resultImage = viewModel.thirdResultCardImage
        thirdResultCard.linkImage = nil
        thirdResultCard?.contentView?.backgroundColor = .brandAccent20
    }

    private func configureYellowBackgroundAndIcon() {
        let yellowCard = viewModel.thirdCardIsHidden ? secondResultCard : thirdResultCard
        yellowCard?.contentView?.backgroundColor = .resultYellowBackground
        yellowCard?.contentView?.layer.borderColor = UIColor.resultYellow.cgColor
        yellowCard?.contentView?.layer.borderWidth = 2
    }

    private func configureContent() {
        subtitleLabel.attributedText = viewModel.subtitle.styledAs(.body).colored(.onBackground110)
        configureIgnoreView()
        configureFirstCard()
        configureSecondCard()
        configureThirdCard()
        configureYellowBackgroundAndIcon()
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
            viewModel.close()
        }
    }

    private func setupGradientBottomView() {
        bottomStackView.layoutIfNeeded()
        scrollView.contentInset.bottom = bottomStackView.bounds.height
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bottomStackView.bounds
        gradientLayer.colors = [UIColor(white: 1, alpha: 0).cgColor, UIColor.backgroundPrimary.cgColor, UIColor.backgroundPrimary.cgColor]
        bottomStackView.layer.insertSublayer(gradientLayer, at: 0)
    }

    @IBAction func footerLinkTapped(_: Any) {
        viewModel.ignoreButton()
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
