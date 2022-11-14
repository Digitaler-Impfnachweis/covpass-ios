//
//  WebviewViewController.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import UIKit
import WebKit

open class WebviewViewController: UIViewController {
    // MARK: - Properties

    let viewModel: WebviewViewModelProtocol
    @IBOutlet var webView: StaticWebView!
    @IBOutlet weak var toolbar: CustomToolbarView!

    // MARK: - Lifecycle

    public init(viewModel: WebviewViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: String(describing: Self.self), bundle: .module)
    }

    @available(*, unavailable)
    public required init?(coder _: NSCoder) { fatalError("init?(coder: NSCoder) not implemented yet") }

    override public func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .neutralWhite
        setupTitle()
        setupNavigationBar()
        webView.backgroundColor = .neutralWhite
        webView.navigationDelegate = self
        webView.load(viewModel.urlRequest)
    }

    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIAccessibility.post(notification: .layoutChanged, argument: viewModel.openingAnnounce)
    }
    
    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        UIAccessibility.post(notification: .layoutChanged, argument: viewModel.closingAnnounce)
    }
    
    private func setupTitle() {
        if navigationController?.navigationBar.backItem != nil {
            title = viewModel.title
            return
        }
        let label = UILabel()
        label.attributedText = viewModel.title?.styledAs(.header_3)
        label.accessibilityTraits = .header
        navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: label)
    }

    private func setupNavigationBar() {
        toolbar.isHidden = !viewModel.isToolbarShown
        if viewModel.isToolbarShown {
            toolbar.delegate = self
            toolbar.setUpLeftButton(leftButtonItem: .navigationArrow)
            return
        }

        if navigationController?.navigationBar.backItem == nil {
            let button = UIButton(type: .custom)
            button.setImage(.close, for: .normal)
            button.accessibilityLabel = "accessibility_certificate_add_popup_label_close".localized
            button.addTarget(self, action: #selector(backButtonPressed), for: .touchUpInside)
            button.frame = CGRect(x: 0, y: 0, width: 32, height: 32)
            navigationItem.rightBarButtonItem = UIBarButtonItem(customView: button)
            navigationController?.navigationBar.setValue(true, forKey: "hidesShadow")
            navigationController?.navigationBar.barTintColor = .neutralWhite
        } else {
            let backButton = UIBarButtonItem(image: .arrowBack, style: .done, target: self, action: #selector(backButtonTapped))
            backButton.accessibilityLabel = "accessibility_app_information_contact_label_back".localized // TODO change accessibility text when they are available
            navigationItem.leftBarButtonItem = backButton
            navigationController?.navigationBar.tintColor = .onBackground100
        }
    }

    @objc func backButtonPressed() {
        dismiss(animated: true, completion: nil)
    }

    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
}

extension WebviewViewController: WKNavigationDelegate {
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if webView != self.webView {
            decisionHandler(.allow)
            return
        }
        if let url = navigationAction.request.url {
            if navigationAction.targetFrame == nil, UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                decisionHandler(.cancel)
                return
            }
            if url.scheme == "tel" || url.scheme == "mailto", UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                decisionHandler(.cancel)
                return
            }
        }
        decisionHandler(.allow)
    }

    public func webView(_: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        guard let serverTrust = challenge.protectionSpace.serverTrust else {
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }
        DispatchQueue.global(qos: .userInitiated).async {
            let exceptions = SecTrustCopyExceptions(serverTrust)
            SecTrustSetExceptions(serverTrust, exceptions)
            completionHandler(.useCredential, URLCredential(trust: serverTrust))
        }
    }

    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if !webView.isLoading {
            self.webView.setDynamicFont()
        }
    }
}

extension WebviewViewController: CustomToolbarViewDelegate {
    public func customToolbarView(_: CustomToolbarView, didTap buttonType: ButtonItemType) {
        switch buttonType {
        case .navigationArrow:
            navigationController?.popViewController(animated: true)
        default:
            break
        }
    }
}
