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
    @IBOutlet var personsStackView: UIStackView!
    @IBOutlet var ignoreView: ParagraphView!
    @IBOutlet var rescanButton: MainButton!
    @IBOutlet var cancelButton: MainButton!
    @IBOutlet var ignoreStackView: UIStackView!
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

    private func configureContent() {
        subtitleLabel.attributedText = viewModel.subtitle.styledAs(.body).colored(.onBackground110)
        configureIgnoreView()

        viewModel.personViewModels.forEach { viewModel in
            let personView = CertResultCard()
            let personTitleLabel = PlainLabel()
            personTitleLabel.attributedText = viewModel.title
                .styledAs(.header_3)
                .colored(.onBackground80)
            personView.title = viewModel.name
                .styledAs(.header_2)
                .colored(.onBackground110)
            personView.subtitle = viewModel.nameTranslittered
                .styledAs(.subheader_2)
                .colored(.onBackground80)
            personView.bottomText = viewModel.dateOfBirth
                .styledAs(.body)
                .colored(.onBackground110)
            personView.isHidden = viewModel.isHidden
            personView.resultImage = viewModel.cardImage
            personView.linkImage = nil
            personView.contentView?.backgroundColor = viewModel.backgroundColor
            personView.contentView?.layer.borderColor = viewModel.borderColor.cgColor
            personView.contentView?.layer.borderWidth = 2
            let personStackView = UIStackView(arrangedSubviews: [personTitleLabel, personView])
            personStackView.spacing = 8
            personStackView.axis = .vertical
            personsStackView.addArrangedSubview(personStackView)
        }
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
