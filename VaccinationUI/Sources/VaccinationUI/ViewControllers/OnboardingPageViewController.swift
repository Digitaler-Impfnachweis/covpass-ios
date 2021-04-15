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

    var viewModel: OnboardingPageViewModel!
    var viewDidLoadAction: (() -> Void)?

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
            image: viewModel.image,
            width: viewModel.imageWidth,
            height: viewModel.imageHeight
        )
        confirmView.detail = nil
        confirmView.imageView.contentMode = viewModel.imageContentMode
        confirmView.contentView?.backgroundColor = viewModel.backgroundColor
    }

    private func configureHeadline() {
        headline.text = viewModel.title
        headline.font = viewModel.headlineFont
        headline.textColor = viewModel.headlineColor
    }

    private func configureParagraphView() {
        paragraphView.title.isHidden = true
        paragraphView.bodyText = viewModel.info
        paragraphView.bodyFont = viewModel.paragraphBodyFont
        paragraphView.contentView?.backgroundColor = viewModel.backgroundColor
    }
}

extension OnboardingPageViewController: StoryboardInstantiating {
    public static var storyboardName: String {
        UIConstants.Storyboard.Onboarding
    }
}
