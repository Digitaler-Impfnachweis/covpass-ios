//
//  StartOnboardingViewController.swift
//  
//
//  Copyright © 2021 IBM. All rights reserved.
//

import UIKit

public class StartOnboardingViewController: UIViewController {

    @IBOutlet public var actionButton: PrimaryButtonContainer!
    @IBOutlet public var confirmView: ConfirmView!
    @IBOutlet public var headline: Headline!
    @IBOutlet public var paragraphView: ParagraphView!
    @IBOutlet public var secureContentView: SecureContentView!
    
    // MARK: - Public Properties
    
    public var viewModel: StartOnboardingViewModel!
    public var router: Router?

    // MARK: - Lifecycle

    public override func viewDidLoad() {
        super.viewDidLoad()
        configureImageView()
        configureHeadline()
        configureParagraphView()
        configureActionButton()
        configureSecureContentView()
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
    
    private func configureActionButton() {
        actionButton.title = viewModel.navigationButtonTitle
        actionButton.action = { [weak self] in
            self?.router?.navigateToNextViewController()
        }
    }
    
    private func configureSecureContentView() {
        secureContentView.title.isHidden = false
        secureContentView.title.font = viewModel.secureHeadlineFont
        secureContentView.title.text = viewModel.secureTitle
        secureContentView.spacing = 0
        secureContentView.bodyText = viewModel.secureText
        secureContentView.bodyFont = viewModel.secureTextFont
        secureContentView.contentView?.backgroundColor = viewModel.backgroundColor
    }
}


// MARK: - StoryboardInstantiating

extension StartOnboardingViewController: StoryboardInstantiating {
    public static var storyboardName: String {
        return UIConstants.Storyboard.Onboarding
    }
}
