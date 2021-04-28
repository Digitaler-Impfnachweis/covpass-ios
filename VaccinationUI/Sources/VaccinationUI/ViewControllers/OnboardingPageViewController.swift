//
//  OnboardingPageViewController.swift
//  
//
//  Copyright © 2021 IBM. All rights reserved.
//

import UIKit

public class OnboardingPageViewController: UIViewController {
    // MARK: - IBOutlets

    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var confirmView: ConfirmView!
    @IBOutlet var headline: PlainLabel!
    @IBOutlet var descriptionText: PlainLabel!
    
    // MARK: - Properties

    var viewModel: BaseViewModel?
    var viewDidLoadAction: (() -> Void)?
    var inputViewModel: OnboardingPageViewModel {
        viewModel as? OnboardingPageViewModel ?? OnboardingPageViewModel(type: .page1)
    }

    // MARK: - Lifecycle

    public override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.contentInset.top = .space_30
        configureImageView()
        configureHeadline()
        configureParagraphView()
        
        viewDidLoadAction?()
    }

    // MARK: - Private

    private func configureImageView() {
        confirmView.kind = .custom(
            image: inputViewModel.image,
            width: inputViewModel.imageWidth,
            height: inputViewModel.imageHeight
        )
        confirmView.detail = nil
        confirmView.imageView.contentMode = inputViewModel.imageContentMode
        confirmView.contentView?.backgroundColor = inputViewModel.backgroundColor
    }

    private func configureHeadline() {
        headline.attributedText = inputViewModel.title.toAttributedString(.h4)
        headline.layoutMargins = .init(top: .space_12, left: .space_24, bottom: .zero, right: .space_24)
    }

    private func configureParagraphView() {
        descriptionText.attributedText = inputViewModel.info.toAttributedString(.body)
        descriptionText.layoutMargins = .init(top: .space_12, left: .space_24, bottom: .zero, right: .space_24)
    }
}

extension OnboardingPageViewController: StoryboardInstantiating {
    public static var storyboardName: String {
        UIConstants.Storyboard.Onboarding
    }
}
