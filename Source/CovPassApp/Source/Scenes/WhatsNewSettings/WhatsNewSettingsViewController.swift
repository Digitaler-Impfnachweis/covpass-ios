//
//  WhatsNewSettingsViewController.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassUI
import UIKit
import WebKit

class WhatsNewSettingsViewController: UIViewController {
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var whatsNewSwitch: LabeledSwitch!
    @IBOutlet var webView: WKWebView!
    @IBOutlet var webViewHeightConstraint: NSLayoutConstraint!
    private var viewModel: WhatsNewSettingsViewModelProtocol

    init(viewModel: WhatsNewSettingsViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        title = viewModel.header
    }

    required init?(coder: NSCoder) { nil }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        setupDescriptionLabel()
        setupWhatsNewSwitch()
        setupWebView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIAccessibility.post(notification: .layoutChanged, argument: viewModel.accessibilityAnnouncementOpen)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        UIAccessibility.post(notification: .layoutChanged, argument: viewModel.accessibilityAnnouncementClose)
    }

    private func setupView() {
        view.backgroundColor = .backgroundPrimary

        let backButton = UIBarButtonItem(image: .arrowBack, style: .done, target: self, action: #selector(backButtonTapped))
        backButton.accessibilityLabel = "accessibility_app_information_contact_label_back".localized // TODO change accessibility text when they are available
        navigationItem.leftBarButtonItem = backButton
        navigationController?.navigationBar.tintColor = .onBackground100
    }

    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }

    private func setupDescriptionLabel() {
        descriptionLabel.attributedText = viewModel.description.styledAs(.body)
        descriptionLabel.accessibilityTraits = .staticText
    }

    private func setupWhatsNewSwitch() {
        whatsNewSwitch.label.attributedText = viewModel
            .switchTitle
            .styledAs(.header_3)
            .colored(.onBackground110)
        whatsNewSwitch.switchChanged = { [weak self] isOn in
            self?.viewModel.disableWhatsNew = !isOn
        }
        whatsNewSwitch.uiSwitch.isOn = !viewModel.disableWhatsNew
        whatsNewSwitch.updateAccessibility()
    }

    private func setupWebView() {
        webView.scrollView.isScrollEnabled = false
        webView.navigationDelegate = self
        webView.load(viewModel.whatsNewURLRequest)
    }
}

// MARK: - WKNavigationDelegate

extension WhatsNewSettingsViewController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if !webView.isLoading {
            webView.evaluateJavaScript("document.body.scrollHeight", completionHandler: { result, _ in
                if let height = result as? CGFloat {
                    self.webViewHeightConstraint.constant = height
                }
            })
        }
    }
}
