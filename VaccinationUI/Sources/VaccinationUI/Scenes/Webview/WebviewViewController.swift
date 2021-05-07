//
//  WebviewViewController.swift
//  
//
//  Copyright © 2021 IBM. All rights reserved.
//

import UIKit
import WebKit

open class WebviewViewController: UIViewController {
    // MARK: - Properties

    let viewModel: WebviewViewModelProtocol
    @IBOutlet var webView: WKWebView!

    // MARK: - Lifecycle

    public init(viewModel: WebviewViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: String(describing: Self.self), bundle: .module)
    }

    @available(*, unavailable)
    required public init?(coder _: NSCoder) { fatalError("init?(coder: NSCoder) not implemented yet") }

    override public func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .neutralWhite
        webView.backgroundColor = .neutralWhite
        webView.load(viewModel.urlRequest)
    }
}
