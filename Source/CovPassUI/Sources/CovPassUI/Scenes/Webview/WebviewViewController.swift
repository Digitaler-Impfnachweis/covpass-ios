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
    @IBOutlet var webView: WKWebView!
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

    private func setupTitle() {
        if navigationController?.navigationBar.backItem != nil {
            title = viewModel.title
            return
        }
        let label = UILabel()
        label.attributedText = viewModel.title?.styledAs(.header_3)
        navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: label)
    }

    private func setupNavigationBar() {
        toolbar.isHidden = !viewModel.isToolbarShown
        if viewModel.isToolbarShown {
            toolbar.delegate = self
            toolbar.setUpLeftButton(leftButtonItem: .navigationArrow)
            return
        }

        if navigationController?.navigationBar.backItem != nil { return }
        let button = UIButton(type: .custom)
        button.setImage(.close, for: .normal)
        button.accessibilityLabel = "accessibility_certificate_add_popup_label_close".localized
        button.addTarget(self, action: #selector(backButtonPressed), for: .touchUpInside)
        button.frame = CGRect(x: 0, y: 0, width: 32, height: 32)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: button)
        navigationController?.navigationBar.setValue(true, forKey: "hidesShadow")
        navigationController?.navigationBar.barTintColor = .neutralWhite
    }

    @objc func backButtonPressed() {
        dismiss(animated: true, completion: nil)
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
        let exceptions = SecTrustCopyExceptions(serverTrust)
        SecTrustSetExceptions(serverTrust, exceptions)
        completionHandler(.useCredential, URLCredential(trust: serverTrust))
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
