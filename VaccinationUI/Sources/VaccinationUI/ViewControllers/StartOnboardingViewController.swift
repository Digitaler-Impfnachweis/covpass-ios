//
//  StartOnboardingViewController.swift
//  
//
//  Copyright © 2021 IBM. All rights reserved.
//

import UIKit

public class StartOnboardingViewController: UIViewController {
    @IBOutlet public var stackView: UIStackView!
    @IBOutlet public var actionButton: MainButton!
    @IBOutlet public var confirmView: ConfirmView!
    @IBOutlet public var headline: PlainLabel!
    @IBOutlet public var subtitle: PlainLabel!
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
        configureImageView()
        configureHeadline()
        configureSubtitle()
        configureActionButton()
        configureSecureContentView()
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
        headline.attributedText = inputViewModel.title.toAttributedString(.h2)
        headline.layoutMargins = .init(top: .space_12, left: .space_24, bottom: .zero, right: .space_24)
    }

    private func configureSubtitle() {
        subtitle.attributedText = inputViewModel.info.toAttributedString(.body)
        subtitle.layoutMargins = .init(top: .space_24, left: .space_24, bottom: .zero, right: .space_24)
    }
    
    private func configureActionButton() {
        actionButton.title = inputViewModel.navigationButtonTitle
        actionButton.style = .primary
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
