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
    @IBOutlet weak var subtitle: UILabel!
    @IBOutlet weak var gProofHeadline: UILabel!
    @IBOutlet weak var gProofResults: CertResultCard!
    @IBOutlet weak var testProofHeadline: UILabel!
    @IBOutlet weak var testProofResults: CertResultCard!
    @IBOutlet weak var footerHeadline: UILabel!
    @IBOutlet weak var footerText: UILabel!
    @IBOutlet weak var footerLink: UILabel!
    @IBOutlet weak var retryButton: MainButton!
    @IBOutlet weak var startOverButton: MainButton!
    @IBOutlet weak var footerStack: UIStackView!
    
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
        subtitle.attributedText = viewModel.subtitle.styledAs(.body)
        footerHeadline.attributedText = viewModel.footerHeadline.styledAs(.header_3)
        footerText.attributedText = viewModel.footerText.styledAs(.body)
        footerLink.attributedText = viewModel.footerLinkText.styledAs(.header_3).colored(.brandAccent)
        footerStack.isHidden = viewModel.isDateOfBirthDifferent

        let resultTitleStyle: TextStyle = .header_2
        let resultSubTitleStyle: TextStyle = .subheader_2

        gProofHeadline.attributedText = viewModel.gProofTitle.styledAs(.subheader_2)
        gProofResults.resultImage = viewModel.gProofCardImage
        gProofResults.title = viewModel.gProofName.styledAs(resultTitleStyle)
        gProofResults.subtitle = viewModel.gProofNameTranslittered.styledAs(resultSubTitleStyle)
        gProofResults.linkImage = nil
        gProofResults.bottomText = viewModel.gProofDateOfBirth.styledAs(.body)
        
        testProofHeadline.attributedText = viewModel.testProofTitle.styledAs(.subheader_2)
        testProofResults.resultImage = viewModel.testProofCardImage
        testProofResults.title = viewModel.testProofName.styledAs(resultTitleStyle)
        testProofResults.subtitle = viewModel.testProofNameTranslittered.styledAs(resultSubTitleStyle)
        testProofResults.linkImage = nil
        testProofResults.bottomText = viewModel.testProofDateOfBirth.styledAs(.body)
        testProofResults.contentView?.backgroundColor = .resultYellowBackground
        testProofResults.contentView?.layer.borderColor = UIColor.resultYellow.cgColor
        testProofResults.contentView?.layer.borderWidth = 2
    }
    
    private func configureAccessiblity() {
    }
    
    @IBAction func footerLinkTapped(_ sender: Any) {
        viewModel.cancel()
    }
}

extension GProofDifferentPersonViewController: ViewModelDelegate {
    func viewModelDidUpdate() {
        self.configureContent()
    }
    
    func viewModelUpdateDidFailWithError(_ error: Error) {
        
    }
    
    
}
