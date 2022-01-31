//
//  GProofViewController.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import UIKit
import CovPassUI

class GProofViewController: UIViewController {
    
    // MARK: - Properties
    @IBOutlet var headline: InfoHeaderView!
    @IBOutlet var certStack: UIStackView!
    @IBOutlet var personStack: UIStackView!
    @IBOutlet var buttonStack: UIStackView!
    @IBOutlet var buttonScanTest: MainButton!
    @IBOutlet var buttonStartOver: MainButton!
    @IBOutlet var buttonScanGProof: MainButton!
    @IBOutlet var buttonRetry: MainButton!
    @IBOutlet var personStackHeadline: UILabel!
    @IBOutlet var pageFooter: UILabel!
    @IBOutlet var resultGProof: CertResultCard!
    @IBOutlet var resultTest: CertResultCard!
    @IBOutlet var resultPerson: CertResultCard!
    
    private(set) var viewModel: GProofViewModelProtocol

    // MARK: - Lifecycle

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init?(coder: NSCoder) not implemented yet")
    }

    init(viewModel: GProofViewModelProtocol) {
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
        configureAccessiblity()
        configureContent()
    }
    
    private func configureHeadline() {
        headline.attributedTitleText = viewModel.title.styledAs(.header_1)
        headline.action = viewModel.cancel
        headline.image = .close
        headline.layoutMargins.bottom = .space_24
    }
    
    private func configureButtons() {
        buttonScanTest.style = .primary
        buttonScanTest.title = viewModel.buttonScanTest
        buttonScanTest.isHidden = viewModel.buttonScanTestIsHidden
        buttonScanTest.action = viewModel.scanTest
        buttonRetry.style = .primary
        buttonRetry.title = viewModel.buttonRetry
        buttonRetry.isHidden = viewModel.buttonRetryIsHidden
        buttonRetry.action = viewModel.retry
        let allOtherThreeButtonsAreHidden = viewModel.buttonScanTestIsHidden && viewModel.buttonRetryIsHidden && viewModel.buttonScan2GIsHidden
        buttonStartOver.style = allOtherThreeButtonsAreHidden ? .primary : .alternative
        buttonStartOver.title = viewModel.buttonStartOver
        buttonStartOver.isHidden = viewModel.buttonStartOverIsHidden
        buttonStartOver.action = viewModel.startover
        buttonScanGProof.style = .primary
        buttonScanGProof.title = viewModel.buttonScan2G
        buttonScanGProof.isHidden = viewModel.buttonScan2GIsHidden
        buttonScanGProof.action = viewModel.scan2GProof
        resultGProof.action = viewModel.showResultGProof
        resultTest.action = viewModel.showResultTestProof
    }
    
    private func configureContent() {
        personStack.isHidden = viewModel.onlyOneIsScannedAndThisFailed
        pageFooter.attributedText = viewModel.footnote.styledAs(.subheader_2)
        pageFooter.isHidden = viewModel.testResultViewIsHidden
        personStackHeadline.attributedText = viewModel.checkIdMessage.styledAs(.subheader_2)
        let resultTitleStyle: TextStyle = .header_2
        
        let linkIsAvailabelForGProof = viewModel.resultGProofLinkImage != nil
        let linkIsAvailabelForTestProof = viewModel.resultTestLinkImage != nil
        let defaultSubTitleStyle: TextStyle = .subheader_2
        let linkBottomTextStyle: TextStyle = .header_3
        let defaultSubTitleColor: UIColor = .gray
        let linkBottomColor: UIColor = .brandAccent
        
        let subTitleStyleGProof: TextStyle = linkIsAvailabelForGProof ? linkBottomTextStyle : defaultSubTitleStyle
        let subTitleStyleTestProof: TextStyle = linkIsAvailabelForTestProof ? linkBottomTextStyle : defaultSubTitleStyle
        let subTitleColorGProof: UIColor = linkIsAvailabelForGProof ? linkBottomColor : defaultSubTitleColor
        let subTitleColorTestProof: UIColor = linkIsAvailabelForTestProof ? linkBottomColor : defaultSubTitleColor

        resultGProof.resultImage = viewModel.resultGProofImage
        resultGProof.title = viewModel.resultGProofTitle.styledAs(resultTitleStyle)
        resultGProof.subtitle = viewModel.resultGProofSubtitle?.styledAs(subTitleStyleGProof).colored(subTitleColorGProof)
        resultGProof.linkImage = viewModel.resultGProofLinkImage
        resultGProof.bottomText = viewModel.resultGProofFooter?.styledAs(.header_1)
        
        resultTest.isHidden = viewModel.testResultViewIsHidden
        resultTest.resultImage = viewModel.resultTestImage
        resultTest.title = viewModel.resultTestTitle.styledAs(resultTitleStyle)
        resultTest.subtitle = viewModel.resultTestSubtitle?.styledAs(subTitleStyleTestProof).colored(subTitleColorTestProof)
        resultTest.linkImage = viewModel.resultTestLinkImage
        resultTest.bottomText = viewModel.resultTestFooter?.styledAs(.header_1)
        
        resultPerson.resultImage = viewModel.resultPersonIcon
        resultPerson.title = viewModel.resultPersonTitle?.styledAs(resultTitleStyle)
        resultPerson.subtitle = viewModel.resultPersonSubtitle?.styledAs(defaultSubTitleStyle)
        resultPerson.bottomText = viewModel.resultPersonFooter?.styledAs(.body)
        resultPerson.linkImage = nil
    }

    private func configureAccessiblity() {
        headline.actionButton.enableAccessibility(label: viewModel.accessibilityResultAnnounceClose)
    }
}

extension GProofViewController: ViewModelDelegate {
    func viewModelDidUpdate() {
        self.configureView()
    }
    
    func viewModelUpdateDidFailWithError(_ error: Error) {
        
    }
}
