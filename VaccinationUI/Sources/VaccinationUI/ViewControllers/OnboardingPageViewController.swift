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
    @IBOutlet var imageView: UIImageView!
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
        scrollView.contentInset.top = .space_70
        configureImageView()
        configureHeadline()
        configureParagraphView()
        
        viewDidLoadAction?()
    }

    // MARK: - Private

    private func configureImageView() {
        imageView.image = inputViewModel.image
        imageView.scaleAspectFit()
    }

    private func configureHeadline() {
        headline.attributedText = inputViewModel.title.styledAs(.header_2)
        headline.layoutMargins = .init(top: .space_40, left: .space_24, bottom: .zero, right: .space_24)
    }

    private func configureParagraphView() {
        descriptionText.attributedText = inputViewModel.info.styledAs(.body).colored(.onBackground70)
        descriptionText.layoutMargins = .init(top: .space_12, left: .space_24, bottom: .zero, right: .space_24)
    }
}

extension OnboardingPageViewController: StoryboardInstantiating {
    public static var storyboardName: String {
        UIConstants.Storyboard.Onboarding
    }
}
