//
//  CertificateViewController.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassUI
import UIKit

class CertificateViewController: UIViewController {
    // MARK: - IBOutlet

    @IBOutlet var headline: InfoHeaderView!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var toolbarView: CustomToolbarView!

    // MARK: - Properties

    private(set) var viewModel: CertificateViewModel

    // MARK: - Lifecycle

    @available(*, unavailable)
    required init?(coder _: NSCoder) { fatalError("init?(coder: NSCoder) not implemented yet") }

    init(viewModel: CertificateViewModel) {
        self.viewModel = viewModel
        super.init(nibName: String(describing: Self.self), bundle: .main)
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configureImageView()
        configureHeadline()
        configureToolbarView()
    }

    // MARK: - Private

    private func configureImageView() {
        imageView.image = viewModel.image
        imageView.pinHeightToScaleAspectFit()
    }

    private func configureHeadline() {
        headline.attributedTitleText = viewModel.title.styledAs(.header_2)
        headline.action = { [weak self] in
            self?.viewModel.cancel()
        }
        headline.image = .close
    }

    private func configureToolbarView() {
        toolbarView.state = .confirm("vaccination_certificate_detail_view_qrcode_screen_action_button_title".localized)
        toolbarView.setUpLeftButton(leftButtonItem: .disabledTextButton)
        toolbarView.layoutMargins.top = .space_24
        toolbarView.delegate = self
    }
}

// MARK: - CustomToolbarViewDelegate

extension CertificateViewController: CustomToolbarViewDelegate {
    func customToolbarView(_: CustomToolbarView, didTap buttonType: ButtonItemType) {
        switch buttonType {
        case .navigationArrow:
            viewModel.cancel()
        case .textButton:
            viewModel.done()
        default:
            return
        }
    }
}

// MARK: - ModalInteractiveDismissibleProtocol

extension CertificateViewController: ModalInteractiveDismissibleProtocol {
    func modalViewControllerDidDismiss() {
        viewModel.cancel()
    }
}
