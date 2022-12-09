//
//  AnnouncementViewController.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import UIKit
import WebKit

public class DataPrivacyViewController: UIViewController {
    // MARK: - IBOutlet

    @IBOutlet var webView: StaticWebView!
    @IBOutlet var toolbarView: CustomToolbarView!

    // MARK: - Properties

    private(set) var viewModel: DataPrivacyViewModel

    // MARK: - Lifecycle

    @available(*, unavailable)
    required init?(coder _: NSCoder) { fatalError("init?(coder: NSCoder) not implemented yet") }

    public init(viewModel: DataPrivacyViewModel) {
        self.viewModel = viewModel
        super.init(nibName: String(describing: Self.self), bundle: .uiBundle)
    }

    // MARK: - Lifecycle

    override public func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.backgroundPrimary
        configureWebView()
        configureToolbarView()
    }

    // MARK: - Private

    private func configureWebView() {
        webView.load(viewModel.webViewRequest)
    }

    private func configureToolbarView() {
        toolbarView.state = .confirm("dialog_update_info_notification_action_button".localized(bundle: .main))
        toolbarView.layoutMargins.top = .space_24
        toolbarView.delegate = self
    }
}

// MARK: - CustomToolbarViewDelegate

extension DataPrivacyViewController: CustomToolbarViewDelegate {
    public func customToolbarView(_: CustomToolbarView, didTap buttonType: ButtonItemType) {
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
    public func modalViewControllerDidDismiss() {
        viewModel.cancel()
    }
}
