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
    @IBOutlet var headline: InfoHeaderView!

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
        configureHeadline()
        webView.backgroundColor = .neutralWhite
        webView.enableTextScaling()
        webView.load(viewModel.urlRequest)
    }

    private func configureHeadline() {
        headline.layoutMargins = .init(top: .zero, left: .space_12, bottom: .zero, right: .space_12)
        headline.attributedTitleText = viewModel.title?.styledAs(.header_2)
        if viewModel.closeButtonShown {
            headline.image = .close
            headline.action = {
                self.dismiss(animated: true)
            }
        }
    }
}
