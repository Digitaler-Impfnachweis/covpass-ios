//
//  RuleCheckViewController.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassUI
import UIKit

class RuleCheckViewController: UIViewController {
    // MARK: - IBOutlet

    @IBOutlet var headline: InfoHeaderView!
    @IBOutlet var subtitle: PlainLabel!
    @IBOutlet var info: LinkLabel!

    // MARK: - Properties

    private(set) var viewModel: RuleCheckViewModel

    // MARK: - Lifecycle

    @available(*, unavailable)
    required init?(coder _: NSCoder) { fatalError("init?(coder: NSCoder) not implemented yet") }

    init(viewModel: RuleCheckViewModel) {
        self.viewModel = viewModel
        super.init(nibName: String(describing: Self.self), bundle: .main)
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configureText()
    }

    // MARK: - Private

    private func configureText() {
        headline.attributedTitleText = "certificate_check_validity_title".localized.styledAs(.header_2)
        headline.action = { [weak self] in
            self?.viewModel.cancel()
        }
        headline.image = .close
        headline.layoutMargins.bottom = .space_24

        subtitle.attributedText = "certificate_check_validity_message".localized.styledAs(.body)
        subtitle.layoutMargins = .init(top: .zero, left: .space_24, bottom: .space_24, right: .space_24)

        info.attributedText = "certificate_check_validity_selection_country_note".localized.styledAs(.body)
        info.layoutMargins = .init(top: .space_8, left: .space_8, bottom: .space_8, right: .space_8)
        info.backgroundColor = .backgroundSecondary20
        info.layer.borderWidth = 1.0
        info.layer.borderColor = UIColor.onBackground20.cgColor
        info.layer.cornerRadius = 12.0
    }
}
