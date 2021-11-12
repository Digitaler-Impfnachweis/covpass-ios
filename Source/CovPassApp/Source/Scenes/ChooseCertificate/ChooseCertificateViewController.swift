//
//  ChooseCertificateViewController.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import CovPassUI
import PromiseKit
import Scanner
import UIKit

class ChooseCertificateViewController: UIViewController {
    // MARK: - Outlets

    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var stackView: UIStackView!
    @IBOutlet var vaccinationsStackView: UIStackView!
    @IBOutlet var headline: InfoHeaderView!
    @IBOutlet var subtitleLabel: PlainLabel!
    @IBOutlet var certDetailsLabel: PlainLabel!
    @IBOutlet var toolbarView: CustomToolbarView!
    
    // MARK: - Properties

    private(set) var viewModel: ChooseCertificateViewModelProtocol

    // MARK: - Lifecycle

    @available(*, unavailable)
    required init?(coder _: NSCoder) { fatalError("init?(coder: NSCoder) not implemented yet") }

    init(viewModel: ChooseCertificateViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: String(describing: Self.self), bundle: .main)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.delegate = self
        setupConstants()
        updateView()
        viewModel.refreshCertificates()
    }

    // MARK: - Methods

    private func setupConstants() {
        setupTitle()
        setupSubtitle()
        view.backgroundColor = .backgroundPrimary
        scrollView.contentInset = .init(top: .space_24, left: .zero, bottom: .space_70, right: .zero)
    }
    
    private func setupTitle() {
        headline.attributedTitleText = viewModel.title.styledAs(.header_2)
        headline.action = { [weak self] in
            self?.viewModel.cancel()
        }
        headline.image = .close
        headline.actionButton.enableAccessibility(label: Constant.Accessibility.labelClose)
    }
    
    private func setupSubtitle() {
        subtitleLabel.attributedText = viewModel.subtitle.styledAs(.header_3)
        subtitleLabel.layoutMargins = .init(top: .zero, left: .space_24, bottom: .zero, right: .space_24)
    }
    
    private func updateView() {
        updateCertDetails()
        updateCertificates()
        updateToolbarView()
    }
    
    private func updateCertDetails() {
        certDetailsLabel.attributedText = viewModel.certdetails.styledAs(.subheader_2).colored(.onBackground100)
        certDetailsLabel.layoutMargins = .init(top: .zero, left: .space_24, bottom: .zero, right: .space_24)
        stackView.setCustomSpacing(40, after: certDetailsLabel)
    }
    
    private func updateCertificates() {
        vaccinationsStackView.subviews.forEach {
            $0.removeFromSuperview()
            self.vaccinationsStackView.removeArrangedSubview($0)
        }
        viewModel.items.forEach {
            self.vaccinationsStackView.addArrangedSubview($0)
        }
    }
    
    private func updateToolbarView() {
        toolbarView.state = .confirm(Constant.Keys.NoMatch.actionButton)
        toolbarView.setUpLeftButton(leftButtonItem: .navigationArrow)
        toolbarView.layoutMargins.top = .space_24
        toolbarView.delegate = self
        toolbarView.primaryButton.isHidden = viewModel.certificatesAvailable
    }
}

extension ChooseCertificateViewController: ViewModelDelegate {
    func viewModelDidUpdate() {
        updateView()
    }

    func viewModelUpdateDidFailWithError(_: Error) {
        // already handled in ViewModel
    }
}

// MARK: - CustomToolbarViewDelegate

extension ChooseCertificateViewController: CustomToolbarViewDelegate {
    func customToolbarView(_: CustomToolbarView, didTap buttonType: ButtonItemType) {
        switch buttonType {
        case .navigationArrow:
            viewModel.cancel()
        case .textButton:
            viewModel.cancel()
        default:
            return
        }
    }
}
