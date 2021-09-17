//
//  OnboardingPageViewController.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import UIKit

private enum Constants {
    enum Accessibility {
        static let image = VoiceOverOptions.Settings(label: "accessibility_image_alternative_text".localized)
    }
}

public class OnboardingPageViewController: UIViewController {
    // MARK: - IBOutlets

    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var headline: PlainLabel!
    @IBOutlet var descriptionText: PlainLabel!

    // MARK: - Properties

    private(set) var viewModel: OnboardingPageViewModel

    // MARK: - Lifecycle

    @available(*, unavailable)
    required init?(coder _: NSCoder) { fatalError("init?(coder: NSCoder) not implemented yet") }

    public init(viewModel: OnboardingPageViewModel) {
        self.viewModel = viewModel
        super.init(nibName: String(describing: Self.self), bundle: .module)
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.backgroundPrimary
        scrollView.backgroundColor = UIColor.backgroundPrimary
        scrollView.contentInset.bottom = .space_120
        configureImageView()
        configureHeadline()
        configureParagraphView()

        accessibilityLabel = headline.attributedText?.string
    }

    // MARK: - Methods

    private func configureImageView() {
        imageView.image = viewModel.image
        imageView.enableAccessibility(label: Constants.Accessibility.image.label)
        imageView.pinHeightToScaleAspectFit()
    }

    private func configureHeadline() {
        headline.attributedText = viewModel.title?.styledAs(.header_2)
        headline.layoutMargins = .init(top: .space_40, left: .space_24, bottom: .zero, right: .space_24)
    }

    private func configureParagraphView() {
        descriptionText.attributedText = viewModel.info?.styledAs(.body).colored(.onBackground70)
        descriptionText.layoutMargins = .init(top: .space_12, left: .space_24, bottom: .zero, right: .space_24)
    }
}

public extension OnboardingPageViewController {
    // This will move to `viewDidLoad` later once all views are
    // intitalized properly before accessing this
    override var accessibilityElements: [Any]? {
        get {
            let elements = [headline, descriptionText, imageView].compactMap { $0 }
            assert(!elements.isEmpty, "No accessibilityElements! View not loaded?")
            return elements
        }
        set {
            self.accessibilityElements = newValue
        }
    }
}
