//
//  TrustedListDetailsViewController.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import Scanner
import UIKit
import CovPassUI

class TrustedListDetailsViewController: UIViewController {
    // MARK: - IBOutlet
    @IBOutlet var headerView: PlainLabel!
    @IBOutlet var bodyTitleLabel: PlainLabel!
    @IBOutlet var downloadStateHintLabel: PlainLabel!
    @IBOutlet var downloadStateIconImageView: UIImageView!
    @IBOutlet var downloadStateWrapper: UIView!
    @IBOutlet var entryRulesTitleLabel: PlainLabel!
    @IBOutlet var entryRulesSubtitleLabel: PlainLabel!
    @IBOutlet var domesticRulesTitleLabel: PlainLabel!
    @IBOutlet var domesticRulesSubtitleLabel: PlainLabel!
    @IBOutlet var valueSetsTitleLabel: PlainLabel!
    @IBOutlet var valueSetsSubtitleLabel: PlainLabel!
    @IBOutlet var certificateProviderTitleLabel: PlainLabel!
    @IBOutlet var certificateProviderSubtitleLabel: PlainLabel!
    @IBOutlet var countryListTitleLabel: PlainLabel!
    @IBOutlet var countryListSubtitleLabel: PlainLabel!
    @IBOutlet var cancelButton: MainButton!
    @IBOutlet var downloadingHintLabel: PlainLabel!
    @IBOutlet var activityIndicatorWrapper: UIView!
    @IBOutlet public var mainButton: MainButton!
    private let activityIndicator = DotPulseActivityIndicator(frame: CGRect(x: 0, y: 0, width: 100, height: 20))
    
    // MARK: - Properties
    
    private(set) var viewModel: TrustedListDetailsViewModel
    
    // MARK: - Lifecycle
    
    @available(*, unavailable)
    required init?(coder _: NSCoder) { fatalError("init?(coder: NSCoder) not implemented yet") }
    
    public init(viewModel: TrustedListDetailsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: String(describing: Self.self), bundle: .main)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.delegate = self
        view.backgroundColor = .backgroundPrimary
        setupView()
    }
    
    // MARK: - Private Methods
    
    private func setupTitle() {
        if navigationController?.navigationBar.backItem != nil {
            title = viewModel.title
            return
        }
        let label = UILabel()
        label.attributedText = viewModel.title.styledAs(.header_3)
        navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: label)
    }
    
    private func setupButtonActions() {
        mainButton.action = viewModel.refresh
        cancelButton.action = viewModel.cancel
    }
    
    private func setupStaticTexts() {
        headerView.attributedText = viewModel.oflineModusDescription.styledAs(.body)
        mainButton.title = viewModel.offlineModusButton
        mainButton.style = .primary
        cancelButton.title = viewModel.cancelButtonTitle
        cancelButton.style = .plain
        entryRulesTitleLabel.attributedText = viewModel.entryRulesTitle.styledAs(.header_3)
        domesticRulesTitleLabel.attributedText = viewModel.domesticRulesTitle.styledAs(.header_3)
        valueSetsTitleLabel.attributedText = viewModel.valueSetsTitle.styledAs(.header_3)
        certificateProviderTitleLabel.attributedText = viewModel.certificateProviderTitle.styledAs(.header_3)
        countryListTitleLabel.attributedText = viewModel.countryListTitle.styledAs(.header_3)
        downloadingHintLabel.attributedText = viewModel.loadingHintTitle.styledAs(.header_3).colored(.gray)
        bodyTitleLabel.attributedText = viewModel.listTitle.styledAs(.header_2)
    }
    
    private func setupView() {
        setupTitle()
        setupActivityIndicator()
        setupButtonActions()
        updateView()
        setupStaticTexts()
        downloadStateWrapper.layer.cornerRadius = 12.0
    }
    
    private func updateLoadingView(isLoading: Bool) {
        mainButton?.isHidden = isLoading
        downloadingHintLabel.isHidden = !isLoading
        cancelButton.isHidden = !isLoading
        isLoading ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
    }
    
    private func setupActivityIndicator() {
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicatorWrapper.translatesAutoresizingMaskIntoConstraints = false
        activityIndicatorWrapper.addSubview(activityIndicator)
        activityIndicator.topAnchor.constraint(equalTo: activityIndicatorWrapper.topAnchor, constant: 40).isActive = true
        activityIndicator.bottomAnchor.constraint(equalTo: activityIndicatorWrapper.bottomAnchor, constant: -40.0).isActive = true
        activityIndicator.leftAnchor.constraint(equalTo: activityIndicatorWrapper.leftAnchor, constant: 40.0).isActive = true
        activityIndicator.rightAnchor.constraint(equalTo: activityIndicatorWrapper.rightAnchor, constant: -40.0).isActive = true
    }
    
    private func updateView() {
        updateLoadingView(isLoading: viewModel.isLoading)
        downloadStateHintLabel.attributedText = viewModel.downloadStateHintTitle.styledAs(.label).colored(viewModel.downloadStateTextColor)
        downloadStateIconImageView.image = viewModel.downloadStateHintIcon
        downloadStateWrapper.backgroundColor = viewModel.downloadStateHintColor
        entryRulesSubtitleLabel.attributedText = viewModel.entryRulesSubtitle.styledAs(.body)
        domesticRulesSubtitleLabel.attributedText = viewModel.domesticRulesSubtitle.styledAs(.body)
        valueSetsSubtitleLabel.attributedText = viewModel.valueSetsSubtitle.styledAs(.body)
        certificateProviderSubtitleLabel.attributedText = viewModel.certificateProviderSubtitle.styledAs(.body)
        countryListSubtitleLabel.attributedText = viewModel.countryListSubtitle.styledAs(.body)
    }
}

extension TrustedListDetailsViewController: ViewModelDelegate {
    public func viewModelDidUpdate() {
        updateView()
    }
    
    public func viewModelUpdateDidFailWithError(_: Error) {}
}
