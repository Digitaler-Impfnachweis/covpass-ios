//
//  SundownInfoViewController.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import UIKit
import WebKit

public class SundownInfoViewController: UIViewController {
    // MARK: - IBOutlet

    @IBOutlet var imageView: UIImageView!
    @IBOutlet var titleLabel: PlainLabel!
    @IBOutlet var copyLabel: PlainLabel!
    @IBOutlet var subtitleLabel: PlainLabel!
    @IBOutlet var bulletPointLabel: PlainLabel!
    @IBOutlet var textStackview: UIStackView!

    // MARK: - Properties

    private var viewModel: SundownInfoViewModelProtocol

    // MARK: - Lifecycle

    @available(*, unavailable)
    required init?(coder _: NSCoder) { fatalError("init?(coder: NSCoder) not implemented yet") }

    init(viewModel: SundownInfoViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: String(describing: Self.self), bundle: .uiBundle)
    }

    // MARK: - Lifecycle

    override public func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }

    @IBAction func closeButtonTapped(_: Any) {
        viewModel.cancel()
    }

    // MARK: - Private

    private func configureView() {
        imageView.image = viewModel.image
        imageView.accessibilityLabel = viewModel.imageDescription
        titleLabel.attributedText = viewModel.title.styledAs(.header_2)
        copyLabel.attributedText = viewModel.copy.styledAs(.body)
        subtitleLabel.attributedText = viewModel.subtitle.styledAs(.header_3)
        bulletPointLabel.attributedText = viewModel.bulletPoints
        textStackview.setCustomSpacing(.space_12, after: titleLabel)
        textStackview.setCustomSpacing(.space_24, after: copyLabel)
        textStackview.setCustomSpacing(.space_8, after: subtitleLabel)
    }
}

// MARK: - ModalInteractiveDismissibleProtocol

extension SundownInfoViewController: ModalInteractiveDismissibleProtocol {
    public func modalViewControllerDidDismiss() {
        viewModel.cancel()
    }
}
