//
//  ConsentViewController.swift
//  
//
//  Copyright © 2021 IBM. All rights reserved.
//

import UIKit
import WebKit

class ConsentViewController: UIViewController {
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var headline: PlainLabel!
    @IBOutlet var descriptionText: PlainLabel!
    @IBOutlet var dataPrivacyCheckbox: CheckboxView!

    // MARK: - Properties

    var viewModel: BaseViewModel?
    var inputViewModel: OnboardingPageViewModel {
        viewModel as? OnboardingPageViewModel ?? OnboardingPageViewModel(type: .page4)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.contentInset.top = .space_70
        configureImageView()
        configureHeadline()
        configureParagraphView()
        configureCheckboxes()
    }

    // MARK: - Private

    private func configureImageView() {
        imageView.image = inputViewModel.image
        imageView.pinHeightToScaleAspectFit()
    }

    private func configureHeadline() {
        headline.attributedText = inputViewModel.title.styledAs(.header_2)
        headline.layoutMargins = .init(top: .space_40, left: .space_24, bottom: .zero, right: .space_24)
    }

    private func configureParagraphView() {
        descriptionText.attributedText = inputViewModel.info.styledAs(.body).colored(.onBackground70)
        descriptionText.layoutMargins = .init(top: .space_12, left: .space_24, bottom: .zero, right: .space_24)
    }

    private func configureCheckboxes() {
        dataPrivacyCheckbox.textView.attributedText = inputViewModel.dataPrivacyTitle
        dataPrivacyCheckbox.layoutMargins = .init(top: .space_40, left: .space_24, bottom: .zero, right: .space_24)
    }
}

// MARK: - StoryboardInstantiating

extension ConsentViewController: StoryboardInstantiating {
    public static var storyboardName: String {
        UIConstants.Storyboard.Onboarding
    }
}
