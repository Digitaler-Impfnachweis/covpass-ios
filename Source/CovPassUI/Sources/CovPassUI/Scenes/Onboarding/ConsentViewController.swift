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
        configureAccessibilityRespondsToUserInteraction()
        view.backgroundColor = UIColor.backgroundPrimary
    }

    override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        configureImageView()
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
        imageView.isAccessibilityElement = false
        imageView.isHidden = UIScreen.main.bounds.size.width > UIScreen.main.bounds.size.height
    }

    private func configureHeadline() {
        headline.attributedText = viewModel.title?.styledAs(.header_2)
        headline.enableAccessibility(label: viewModel.title, traits: .header)
        headline.layoutMargins = .init(top: .space_40, left: .space_24, bottom: .zero, right: .space_24)
    }

    private func configureListItems() {
        listItems.layoutMargins = .init(top: .space_24, left: .space_24, bottom: .zero, right: .space_24)
        listItems.enableAccessibility(label: viewModel.listItems.string, traits: .staticText)
        listItems.attributedText = viewModel.listItems
    }

    private func configureParagraphView() {
        descriptionText.attributedText = viewModel.info?.styledAs(.body).colored(.onBackground70)
        descriptionText.layoutMargins = .init(top: .space_40, left: .space_24, bottom: .zero, right: .space_24)
        descriptionText.enableAccessibility(label: viewModel.info, traits: .staticText)
    }

    private func configureInfoView() {
        dataPrivacyInfoView.backgroundColor = UIColor.backgroundPrimary
        dataPrivacyInfoView.textLabel.attributedText = viewModel.dataPrivacyTitle
        dataPrivacyInfoView.action = infoViewAction
        dataPrivacyInfoView.showSeperator = true
        dataPrivacyInfoView.layoutMargins = .init(top: .space_24, left: .zero, bottom: .zero, right: .zero)
        dataPrivacyInfoView.enableAccessibility(label: viewModel.dataPrivacyTitle.string, traits: .button)
    }

    private func configureHintView() {
        usTermsOfUse.style = .info
        let usTermsOfUseTitle = "vaccination_fourth_onboarding_page_message_for_us_citizens_title".localized
        let usTermsOfUseSubtitle = "vaccination_fourth_onboarding_page_message_for_us_citizens_copy".localized
        let usTermsOfUseLink = "vaccination_fourth_onboarding_page_message_for_us_citizens_title".localized
        usTermsOfUse.titleLabel.attributedText = usTermsOfUseTitle.styledAs(.header_3)
        usTermsOfUse.subTitleLabel.attributedText = "\(usTermsOfUseSubtitle)".styledAs(.body)
        usTermsOfUse.bodyLabel.attributedText = "#\(usTermsOfUseLink)::link#".styledAs(.mainButton)
        usTermsOfUse.titleToSubTitleConstraint.constant = 4
        usTermsOfUse.subTitleConstraint.constant = 18
        usTermsOfUse.bodyLabel.linkCallback = { [weak self] _ in
            self?.viewModel.router.showTermsOfUse()
        }
        usTermsOfUse.isHidden = !viewModel.showUSTerms
    }

    private func configureAccessibilityRespondsToUserInteraction() {
        if #available(iOS 13.0, *) {
            headline.accessibilityRespondsToUserInteraction = true
            listItems.accessibilityRespondsToUserInteraction = true
            descriptionText.accessibilityRespondsToUserInteraction = true
            dataPrivacyInfoView.accessibilityRespondsToUserInteraction = true
            usTermsOfUse.accessibilityRespondsToUserInteraction = true
        }
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
