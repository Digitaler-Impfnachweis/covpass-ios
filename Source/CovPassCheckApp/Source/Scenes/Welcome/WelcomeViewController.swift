//
//  WelcomeViewController.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassUI
import UIKit

class WelcomeViewController: UIViewController {
    // MARK: - IBOutlets

    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var bottomView: UIView!
    @IBOutlet var stackView: UIStackView!
    @IBOutlet var actionButton: MainButton!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var headline: PlainLabel!
    @IBOutlet var subtitle: PlainLabel!
    @IBOutlet var secureContentView: SecureContentView!

    // MARK: - Properties

    private(set) var viewModel: WelcomeViewModel

    // MARK: - Lifecycle

    @available(*, unavailable)
    required init?(coder _: NSCoder) { fatalError("init?(coder: NSCoder) not implemented yet") }

    init(viewModel: WelcomeViewModel) {
        self.viewModel = viewModel
        super.init(nibName: String(describing: Self.self), bundle: .main)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        view.backgroundColor = UIColor.backgroundPrimary
        configureScrollView()
        configureImageView()
        configureHeadline()
        configureSubtitle()
        configureActionButton()
        configureSecureContentView()
    }

    // MARK: - Methods

    private func configureScrollView() {
        scrollView.contentInset.bottom = .space_90
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bottomView.bounds
        gradientLayer.colors = [UIColor(white: 1, alpha: 0).cgColor, UIColor.backgroundPrimary.cgColor, UIColor.backgroundPrimary.cgColor]
        bottomView.layer.insertSublayer(gradientLayer, at: 0)
    }

    private func configureImageView() {
        imageView.image = viewModel.image
        imageView.pinHeightToScaleAspectFit()
    }

    private func configureHeadline() {
        headline.attributedText = viewModel.title.styledAs(.display)
        headline.textableView.accessibilityTraits = .header
        headline.layoutMargins = .init(top: .space_24, left: .space_24, bottom: .zero, right: .space_24)
    }

    private func configureSubtitle() {
        subtitle.attributedText = viewModel.info.styledAs(.subheader_1)
        subtitle.layoutMargins = .init(top: .space_12, left: .space_24, bottom: .space_40, right: .space_24)
    }

    private func configureActionButton() {
        actionButton.title = viewModel.navigationButtonTitle
        actionButton.style = .primary
        actionButton.action = { [weak self] in
            self?.viewModel.showNextScene()
        }
    }

    private func configureSecureContentView() {
        secureContentView.titleAttributedString = viewModel.secureTitle.styledAs(.header_3)
        secureContentView.bodyAttributedString = viewModel.secureText.styledAs(.body).colored(.onBackground70)
        secureContentView.contentView?.backgroundColor = .backgroundPrimary
        secureContentView.layoutMargins = .init(top: .space_40, left: .space_24, bottom: .space_50, right: .space_24)
    }
}
