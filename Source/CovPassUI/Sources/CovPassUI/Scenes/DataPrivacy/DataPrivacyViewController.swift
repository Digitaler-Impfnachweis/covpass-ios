//
//  AnnouncementViewController.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import UIKit
import WebKit

class DataPrivacyViewController: UIViewController {
    // MARK: - IBOutlet

    @IBOutlet var webView: WKWebView!
    @IBOutlet var toolbarView: CustomToolbarView!

    // MARK: - Properties

    private(set) var viewModel: DataPrivacyViewModel

    // MARK: - Lifecycle

    @available(*, unavailable)
    required init?(coder _: NSCoder) { fatalError("init?(coder: NSCoder) not implemented yet") }

    init(viewModel: DataPrivacyViewModel) {
        self.viewModel = viewModel
        super.init(nibName: String(describing: Self.self), bundle: .uiBundle)
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configureWebView()
        configureToolbarView()
    }

    // MARK: - Private

    private func configureWebView() {
        guard let request = viewModel.webViewRequest else { return }
        webView.load(request)
    }

    private func configureToolbarView() {
        toolbarView.state = .confirm("dialog_update_info_notification_action_button".localized(bundle: .main))
        toolbarView.layoutMargins.top = .space_24
        toolbarView.delegate = self
    }
}

// MARK: - CustomToolbarViewDelegate

extension DataPrivacyViewController: CustomToolbarViewDelegate {
    func customToolbarView(_: CustomToolbarView, didTap buttonType: ButtonItemType) {
        switch buttonType {
        case .textButton:
            viewModel.done()
        default:
            return
        }
    }
}

// MARK: - ModalInteractiveDismissibleProtocol

extension DataPrivacyViewController: ModalInteractiveDismissibleProtocol {
    func modalViewControllerDidDismiss() {
        viewModel.cancel()
    }
}
