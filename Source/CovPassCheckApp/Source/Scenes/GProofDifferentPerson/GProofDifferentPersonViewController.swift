//
//  File.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import UIKit
import CovPassUI

class GProofDifferentPersonViewController: UIViewController {

    // MARK: - Properties
    
    @IBOutlet weak var headline: InfoHeaderView!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var firstResultHeadlineLabel: UILabel!
    @IBOutlet weak var firstResultCard: CertResultCard!
    @IBOutlet weak var secondResultHeadlineLabel: UILabel!
    @IBOutlet weak var secondResultCard: CertResultCard!
    @IBOutlet weak var footerHeadline: UILabel!
    @IBOutlet weak var footerText: UILabel!
    @IBOutlet weak var footerLink: UILabel!
    @IBOutlet weak var retryButton: MainButton!
    @IBOutlet weak var startOverButton: MainButton!
    @IBOutlet weak var footerStack: UIStackView!
    @IBOutlet weak var counterLabel: UILabel!
    
    private(set) var viewModel: GProofDifferentPersonViewModelProtocol
    
    // MARK: - Lifecycle
    
    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init?(coder: NSCoder) not implemented yet")
    }
    
    init(viewModel: GProofDifferentPersonViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: String(describing: Self.self), bundle: .main)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewModel.delegate = self
        configureView()
    }
    
    private func configureView() {
        configureHeadline()
        configureButtons()
        configureAccessiblity()
        configureContent()
        configureCounter()
    }
    
    private func configureHeadline() {
        headline.attributedTitleText = viewModel.title.styledAs(.header_1)
        headline.action = viewModel.cancel
        headline.image = .close
    }
    
    private func configureButtons() {
        retryButton.style = .primary
        retryButton.title = viewModel.retryButton
        retryButton.action = {
            self.viewModel.retry()
        }
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
        footerStack.isHidden = viewModel.isDateOfBirthDifferent

        let resultTitleStyle: TextStyle = .header_2
        let resultSubTitleStyle: TextStyle = .subheader_2

        firstResultHeadlineLabel.attributedText = viewModel.firstResultTitle.styledAs(.subheader_2)
        firstResultCard.resultImage = viewModel.firstResultCardImage
        firstResultCard.title = viewModel.firstResultName.styledAs(resultTitleStyle)
        firstResultCard.subtitle = viewModel.firstResultNameTranslittered.styledAs(resultSubTitleStyle)
        firstResultCard.linkImage = nil
        firstResultCard.bottomText = viewModel.firstResultDateOfBirth.styledAs(.body)
        
        secondResultHeadlineLabel.attributedText = viewModel.secondResultTitle.styledAs(.subheader_2)
        secondResultCard.resultImage = viewModel.SecondResultCardImage
        secondResultCard.title = viewModel.secondResultName.styledAs(resultTitleStyle)
        secondResultCard.subtitle = viewModel.secondResultNameTranslittered.styledAs(resultSubTitleStyle)
        secondResultCard.linkImage = nil
        secondResultCard.bottomText = viewModel.secondResultDateOfBirth.styledAs(.body)
        secondResultCard.contentView?.backgroundColor = .resultYellowBackground
        secondResultCard.contentView?.layer.borderColor = UIColor.resultYellow.cgColor
        secondResultCard.contentView?.layer.borderWidth = 2
    }
    
    private func configureAccessiblity() {
    }
    
    @IBAction func footerLinkTapped(_ sender: Any) {
        viewModel.cancel()
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
            viewModel.cancel()
        }
    }
}

extension GProofDifferentPersonViewController: ViewModelDelegate {
    func viewModelDidUpdate() {
        self.configureContent()
        self.configureCounter()
        self.dismissIfCountdownIsFinished()
    }
    
    func viewModelUpdateDidFailWithError(_ error: Error) {
        
    }
    
    
}
