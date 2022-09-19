//
//  AnnouncementViewController.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassUI
import UIKit
import WebKit

class AnnouncementViewController: UIViewController {
    // MARK: - IBOutlet

    @IBOutlet var webView: WKWebView!
    @IBOutlet var webViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet var okButton: MainButton!
    @IBOutlet var checkButton: UIButton!
    @IBOutlet var checkTitleLabel: UILabel!
    @IBOutlet var checkDescriptionLabel: UILabel!

    // MARK: - Properties

    private var viewModel: AnnouncementViewModelProtocol

    // MARK: - Lifecycle

    @available(*, unavailable)
    required init?(coder _: NSCoder) { fatalError("init?(coder: NSCoder) not implemented yet") }

    init(viewModel: AnnouncementViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: String(describing: Self.self), bundle: .main)
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configureWebView()
        configureCheckBox()
        configureOkButton()
    }

    // MARK: - Private

    private func configureWebView() {
        webView.scrollView.isScrollEnabled = false
        webView.navigationDelegate = self
        _ = webView.loadSynchronously(viewModel.whatsNewURL)
    }

    private func configureCheckBox() {
        checkTitleLabel.attributedText = viewModel.checkboxTitle
            .styledAs(.header_3)
        checkTitleLabel.accessibilityTraits = .staticText
        checkTitleLabel.accessibilityLabel = viewModel.checkboxTitle
        
        checkDescriptionLabel.attributedText = viewModel.checkboxDescription
            .styledAs(.body)
        checkDescriptionLabel.accessibilityTraits = .staticText

        checkButton.setTitle("", for: .normal)
        checkButton.addTarget(
            self,
            action: #selector(checkButtonPressed),
            for: .primaryActionTriggered
        )
        updateCheckButton()
    }

    private func updateCheckButton() {
        let image: UIImage = viewModel.disableWhatsNew ? .checkboxChecked : .checkboxUnchecked
        checkButton.setImage(image, for: .normal)
        checkTitleLabel.accessibilityValue = viewModel.checkboxAccessibilityValue
    }

    @objc private func checkButtonPressed(button: UIButton) {
        viewModel.disableWhatsNew.toggle()
        updateCheckButton()
    }

    private func configureOkButton() {
        okButton.title =  viewModel.okButtonTitle
        okButton.action = viewModel.done
    }
}

// MARK: - ModalInteractiveDismissibleProtocol

extension AnnouncementViewController: ModalInteractiveDismissibleProtocol {
    func modalViewControllerDidDismiss() {
        viewModel.cancel()
    }
}


// MARK: - WKNavigationDelegate

private extension WKWebView {
    func loadSynchronously(_ url: URL) -> WKNavigation? {
        guard let data = try? Data(contentsOf: url),
              let html = String(data: data, encoding: .utf8)
        else {
            return nil
        }
        return loadHTMLString(html, baseURL: url)
    }
}

extension AnnouncementViewController: WKNavigationDelegate {
    
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
