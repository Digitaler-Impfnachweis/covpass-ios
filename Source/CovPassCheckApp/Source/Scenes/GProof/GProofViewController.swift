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
    @IBOutlet var buttonScanNext: MainButton!
    @IBOutlet var buttonStartOver: MainButton!
    @IBOutlet var buttonRetry: MainButton!
    @IBOutlet var personStackHeadline: UILabel!
    @IBOutlet var pageFooter: UILabel!
    @IBOutlet var firstResultCard: CertResultCard!
    @IBOutlet var seconResultCard: CertResultCard!
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.startover()
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
        buttonScanNext.style = .primary
        buttonScanNext.title = viewModel.buttonScanNextTitle
        buttonScanNext.isHidden = viewModel.scanNextButtonIsHidden
        buttonScanNext.action = viewModel.scanNext
        buttonRetry.style = .primary
        buttonRetry.title = viewModel.buttonRetry
        buttonRetry.isHidden = viewModel.buttonRetryIsHidden
        buttonRetry.action = viewModel.retry
        buttonStartOver.style = viewModel.scanNextButtonIsHidden && viewModel.buttonRetryIsHidden ? .primary : .alternative
        buttonStartOver.title = viewModel.buttonStartOver
        buttonStartOver.isHidden = viewModel.buttonStartOverIsHidden
        buttonStartOver.action = viewModel.startover
        firstResultCard.action = viewModel.showFirstCardResult
        seconResultCard.action = viewModel.showSecondCardResult
    }
    
    private func configureContent() {
        personStack.isHidden = viewModel.personStackIsHidden
        pageFooter.attributedText = viewModel.footnote.styledAs(.subheader_2)
        pageFooter.isHidden = viewModel.pageFooterIsHidden
        personStackHeadline.attributedText = viewModel.checkIdMessage.styledAs(.subheader_2)
        let resultTitleStyle: TextStyle = .header_2
        
        let linkIsAvailabelForFirstResult = viewModel.firstResultLinkImage != nil
        let linkIsAvailabelForSecondResult = viewModel.seconResultLinkImage != nil
        let defaultSubTitleStyleFirstResult: TextStyle = viewModel.firstResult != nil ? .header_2 : .subheader_2
        let defaultSubTitleStyleSecondResult: TextStyle = viewModel.secondResult != nil ? .header_2 : .subheader_2
        let defaultSubTitleStyle: TextStyle = .subheader_2
        let linkBottomTextStyle: TextStyle = .header_3
        let defaultSubTitleColor: UIColor = .gray
        let linkBottomColor: UIColor = .brandAccent
        
        let subTitleStyleFirstResult: TextStyle = linkIsAvailabelForFirstResult ? linkBottomTextStyle : defaultSubTitleStyleFirstResult
        let subTitleStyleSecondResult: TextStyle = linkIsAvailabelForSecondResult ? linkBottomTextStyle : defaultSubTitleStyleSecondResult
        let subTitleColorFirstResult: UIColor = linkIsAvailabelForFirstResult ? linkBottomColor : defaultSubTitleColor
        let subTitleColorSecondResult: UIColor = linkIsAvailabelForSecondResult ? linkBottomColor : defaultSubTitleColor
        
        firstResultCard.resultImage = viewModel.firstResultImage
        firstResultCard.title = viewModel.firstResultTitle.styledAs(resultTitleStyle)
        firstResultCard.subtitle = viewModel.firstResultSubtitle?.styledAs(subTitleStyleFirstResult).colored(subTitleColorFirstResult)
        firstResultCard.linkImage = viewModel.firstResultLinkImage
        firstResultCard.bottomText = viewModel.firstResultFooterText?.styledAs(.header_1)
        
        seconResultCard.isHidden = viewModel.seconResultViewIsHidden
        seconResultCard.resultImage = viewModel.secondResultImage
        seconResultCard.title = viewModel.secondResultTitle.styledAs(resultTitleStyle)
        seconResultCard.subtitle = viewModel.seconResultSubtitle?.styledAs(subTitleStyleSecondResult).colored(subTitleColorSecondResult)
        seconResultCard.linkImage = viewModel.seconResultLinkImage
        seconResultCard.bottomText = viewModel.seconResultFooterText?.styledAs(.header_1)
        
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
