//
//  OnboardingPageViewController.swift
//  
//
//  Copyright © 2021 IBM. All rights reserved.
//

import UIKit

public class OnboardingPageViewController: UIViewController {
    // MARK: - IBOutlets

    @IBOutlet var confirmView: ConfirmView!
    @IBOutlet var headline: Headline!
    @IBOutlet var paragraphView: ParagraphView!
    
    // MARK: - Properties

    var viewModel: BaseViewModel?
    var viewDidLoadAction: (() -> Void)?
    var inputViewModel: OnboardingPageViewModel {
        viewModel as? OnboardingPageViewModel ?? OnboardingPageViewModel(type: .page1)
    }

    // MARK: - Lifecycle

    public override func viewDidLoad() {
        super.viewDidLoad()

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
        headline.text = inputViewModel.title
        headline.font = inputViewModel.headlineFont
        headline.textColor = inputViewModel.headlineColor
    }

    private func configureParagraphView() {
        paragraphView.title.isHidden = true
        paragraphView.bodyText = inputViewModel.info
        paragraphView.bodyFont = inputViewModel.paragraphBodyFont
        paragraphView.contentView?.backgroundColor = inputViewModel.backgroundColor
    }
}

extension OnboardingPageViewController: StoryboardInstantiating {
    public static var storyboardName: String {
        UIConstants.Storyboard.Onboarding
    }
}
