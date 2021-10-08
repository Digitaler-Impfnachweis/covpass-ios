//
//  TrustedListDetailsViewController.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassUI
import Foundation
import Scanner
import UIKit

class TrustedListDetailsViewController: UIViewController {
    // MARK: - IBOutlet
    @IBOutlet var headerView: PlainLabel!
    @IBOutlet var offlineCard: HintView!
    @IBOutlet var mainButton: MainButton!
    let activityIndicator = DotPulseActivityIndicator(frame: CGRect(x: 0, y: 0, width: 100, height: 20))

    // MARK: - Properties
    
    private(set) var viewModel: TrustedListDetailsViewModel
    
    // MARK: - Lifecycle
    
    @available(*, unavailable)
    required init?(coder _: NSCoder) { fatalError("init?(coder: NSCoder) not implemented yet") }
    
    init(viewModel: TrustedListDetailsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: String(describing: Self.self), bundle: .main)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.delegate = self
        view.backgroundColor = .neutralWhite
        setupTitle()
        setupView()
    }
    
    private func setupTitle() {
        if navigationController?.navigationBar.backItem != nil {
            title = viewModel.title
            return
        }
        let label = UILabel()
        label.attributedText = viewModel.title.styledAs(.header_3)
        navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: label)
    }
    
    private func setupMainButtonAction() {
        mainButton.action = { [weak self] in
            self?.viewModel.refresh()
            self?.updateLoadingView(isLoading: self?.viewModel.isLoading ?? true)
        }
    }
    
    private func setupView() {
        addActivityIndicator()
        headerView.attributedText = viewModel.offlineModusInformation.styledAs(.body)
        offlineCard.containerView.backgroundColor = .brandAccent10
        offlineCard.containerView?.layer.borderColor = UIColor.onBackground50.cgColor
        offlineCard.iconView.image = .infoSignal
        offlineCard.titleLabel.attributedText = viewModel.offlineModusNoteUpdate.styledAs(.mainButton) .colored(.onBackground70)
        mainButton.title = viewModel.offlineModusButton
        setupMainButtonAction()
        updateView()
    }
    
    private func updateLoadingView(isLoading: Bool) {
        self.offlineCard.contentView?.isHidden = isLoading
        self.mainButton?.isHidden = isLoading
        isLoading ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
    }
    
    private func updateView() {
        updateLoadingView(isLoading: viewModel.isLoading)
        if let certificateText = viewModel.offlineMessageCertificates,
           let rulesText = viewModel.offlineMessageRules {
            let lastDatesDescription = "\(certificateText)\n\(rulesText)"
                .styledAs(.body)
                .colored(.onBackground70)
            offlineCard.bodyLabel.attributedText = lastDatesDescription
        } else {
            offlineCard.contentView?.isHidden = true
        }
    }
    
    // MARK: - Methods
    
    private func addActivityIndicator() {
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        let activityIndicatorContainer = UIView()
        activityIndicatorContainer.translatesAutoresizingMaskIntoConstraints = false
        activityIndicatorContainer.addSubview(activityIndicator)
        offlineCard.addSubview(activityIndicatorContainer)
        activityIndicatorContainer.centerXAnchor.constraint(equalTo: offlineCard.centerXAnchor).isActive = true
        activityIndicatorContainer.centerYAnchor.constraint(equalTo: offlineCard.centerYAnchor).isActive = true
        activityIndicator.topAnchor.constraint(equalTo: activityIndicatorContainer.topAnchor, constant: 40).isActive = true
        activityIndicator.bottomAnchor.constraint(equalTo: activityIndicatorContainer.bottomAnchor, constant: -40.0).isActive = true
        activityIndicator.leftAnchor.constraint(equalTo: activityIndicatorContainer.leftAnchor, constant: 40.0).isActive = true
        activityIndicator.rightAnchor.constraint(equalTo: activityIndicatorContainer.rightAnchor, constant: -40.0).isActive = true
    }
}

extension TrustedListDetailsViewController: ViewModelDelegate {
    func viewModelDidUpdate() {
        updateView()
    }
    
    func viewModelUpdateDidFailWithError(_: Error) {}
}
