//
//  StartOnboardingViewController.swift
//  
//
//  Copyright © 2021 IBM. All rights reserved.
//

import UIKit

public class StartOnboardingViewController: UIViewController {
    @IBOutlet public var stackView: UIStackView!
    @IBOutlet public var actionButton: PrimaryButtonContainer!
    @IBOutlet public var confirmView: ConfirmView!
    @IBOutlet public var headline: Headline!
    @IBOutlet public var paragraphView: ParagraphView!
    @IBOutlet public var secureContentView: SecureContentView!
    
    // MARK: - Public Properties
    
    public var viewModel: BaseViewModel?
    public var router: Router?

    // MARK: - Internal Properties

    var inputViewModel: StartOnboardingViewModel {
        viewModel as? StartOnboardingViewModel ?? StartOnboardingViewModel()
    }

    // MARK: - Lifecycle

    public override func viewDidLoad() {
        super.viewDidLoad()
        configureStackView()
        configureImageView()
        configureHeadline()
        configureParagraphView()
        configureActionButton()
        configureSecureContentView()
    }

    // MARK: - Private

    private func configureStackView() {
        stackView.setCustomSpacing(40, after: headline)
        stackView.setCustomSpacing(40, after: confirmView)
    }

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
    
    private func configureActionButton() {
        actionButton.title = inputViewModel.navigationButtonTitle
        actionButton.action = { [weak self] in
            self?.router?.navigateToNextViewController()
        }
    }
    
    private func configureSecureContentView() {
        secureContentView.title.isHidden = false
        secureContentView.title.font = inputViewModel.secureHeadlineFont
        secureContentView.title.text = inputViewModel.secureTitle
        secureContentView.spacing = 0
        secureContentView.bodyText = inputViewModel.secureText
        secureContentView.bodyFont = inputViewModel.secureTextFont
        secureContentView.contentView?.backgroundColor = inputViewModel.backgroundColor
    }
}


// MARK: - StoryboardInstantiating

extension StartOnboardingViewController: StoryboardInstantiating {
    public static var storyboardName: String {
        return UIConstants.Storyboard.Onboarding
    }
}
