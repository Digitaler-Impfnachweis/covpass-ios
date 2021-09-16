//
//  BoosterDisclaimerViewController.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassUI
import UIKit

class BoosterDisclaimerViewController: UIViewController {
    @IBOutlet var headline: InfoHeaderView!
    @IBOutlet var detailsView: ParagraphView!
    @IBOutlet var actionButton: MainButton!

    private let viewModel: BoosterDisclaimerViewModel

    // MARK: - Lifecycle

    @available(*, unavailable)
    required init?(coder _: NSCoder) { fatalError("init?(coder: NSCoder) not implemented yet") }

    init(viewModel: BoosterDisclaimerViewModel) {
        self.viewModel = viewModel
        super.init(nibName: String(describing: Self.self), bundle: .main)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        headline.attributedTitleText = viewModel.title.styledAs(.header_2)
        detailsView.attributedBodyText = viewModel.disclaimerText.styledAs(.body)
        detailsView.bottomBorder.isHidden = true

        actionButton.title = viewModel.actionButtonTitle
        actionButton.action = { [weak self] in
            self?.viewModel.resolver.fulfill_()
        }
    }
}
