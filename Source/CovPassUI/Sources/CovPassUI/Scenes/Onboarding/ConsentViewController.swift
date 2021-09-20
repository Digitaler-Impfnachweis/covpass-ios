//
//  ConsentViewController.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import UIKit
import WebKit

private enum Constants {
    enum Accessibility {
        static let image = VoiceOverOptions.Settings(label: "accessibility_image_alternative_text".localized)
    }
}

class ConsentViewController: UIViewController {
    // MARK: - IBOutlets

    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var headline: PlainLabel!
    @IBOutlet var listItems: PlainLabel!
    @IBOutlet var descriptionText: PlainLabel!
    @IBOutlet var dataPrivacyInfoView: ListItemView!
    @IBOutlet var usTermsOfUse: HintView!

    // MARK: - Properties

    private(set) var viewModel: ConsentPageViewModel

    public var infoViewAction: (() -> Void)?

    // MARK: - Lifecycle

    @available(*, unavailable)
    required init?(coder _: NSCoder) { fatalError("init?(coder: NSCoder) not implemented yet") }

    public init(viewModel: ConsentPageViewModel) {
        self.viewModel = viewModel
        super.init(nibName: String(describing: Self.self), bundle: .module)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureScrollView()
        configureImageView()
        configureHeadline()
        configureListItems()
        configureParagraphView()
        configureInfoView()
        configureHintView()
        view.backgroundColor = UIColor.backgroundPrimary
    }

    // MARK: - Methods

    public func scrollToBottom() {
        scrollView.scroll(to: .bottom, with: .space_120, animated: true)
    }

    private func configureScrollView() {
        scrollView.contentInset.bottom = .space_120
        scrollView.delegate = self
    }

    private func configureImageView() {
        imageView.image = viewModel.image
        imageView.pinHeightToScaleAspectFit()
        imageView.enableAccessibility(label: Constants.Accessibility.image.label)
    }

    private func configureHeadline() {
        headline.attributedText = viewModel.title?.styledAs(.header_2)
        headline.layoutMargins = .init(top: .space_40, left: .space_24, bottom: .zero, right: .space_24)
    }

    private func configureListItems() {
        listItems.layoutMargins = .init(top: .space_24, left: .space_24, bottom: .zero, right: .space_24)
        listItems.attributedText = viewModel.listItems
    }

    private func configureParagraphView() {
        descriptionText.attributedText = viewModel.info?.styledAs(.body).colored(.onBackground70)
        descriptionText.layoutMargins = .init(top: .space_40, left: .space_24, bottom: .zero, right: .space_24)
    }

    private func configureInfoView() {
        dataPrivacyInfoView.backgroundColor = UIColor.backgroundPrimary
        dataPrivacyInfoView.textLabel.attributedText = viewModel.dataPrivacyTitle
        dataPrivacyInfoView.action = infoViewAction
        dataPrivacyInfoView.showSeperator = true
        dataPrivacyInfoView.layoutMargins = .init(top: .space_24, left: .zero, bottom: .zero, right: .zero)
    }

    private func configureHintView() {
        usTermsOfUse.iconView.image = .info
        usTermsOfUse.containerView.backgroundColor = .onBackground50
        usTermsOfUse.containerView.layer.borderColor = UIColor.onBrandBase.cgColor
        usTermsOfUse.titleLabel.attributedText = "vaccination_fourth_onboarding_page_message_for_us_citizens_title".localized.styledAs(.header_3)
        usTermsOfUse.bodyLabel.attributedText = "\("vaccination_fourth_onboarding_page_message_for_us_citizens_copy".localized)\n\n#\("vaccination_fourth_onboarding_page_message_for_us_citizens_title".localized)::link#".styledAs(.body)
        usTermsOfUse.bodyLabel.linkCallback = { [weak self] _ in
            self?.viewModel.router.showTermsOfUse()
        }
        usTermsOfUse.isHidden = !viewModel.showUSTerms
    }
}

extension ConsentViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        viewModel.isScrolledToBottom = scrollView.isScrolledToBottom
    }
}

extension ConsentViewController {
    // This will move to `viewDidLoad` later once all views are
    // intitalized properly before accessing this
    override public var accessibilityElements: [Any]? {
        get {
            let elements = [headline, listItems, descriptionText, dataPrivacyInfoView, imageView].compactMap { $0 }
            assert(!elements.isEmpty, "No accessibilityElements! View not loaded?")
            return elements
        }
        set {
            self.accessibilityElements = newValue
        }
    }
}
