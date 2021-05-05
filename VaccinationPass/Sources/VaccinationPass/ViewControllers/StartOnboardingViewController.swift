//
//  StartOnboardingViewController.swift
//  
//
//  Copyright © 2021 IBM. All rights reserved.
//

import UIKit
import VaccinationUI

public class StartOnboardingViewController: UIViewController {
    @IBOutlet public var stackView: UIStackView!
    @IBOutlet public var actionButton: MainButton!
    @IBOutlet public var imageView: UIImageView!
    @IBOutlet public var headline: PlainLabel!
    @IBOutlet public var subtitle: PlainLabel!
    @IBOutlet public var secureContentView: SecureContentView!
    
    // MARK: - Public Properties

    public var viewModel: StartOnboardingViewModel?

    // MARK: - Lifecycle

    public override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        configureImageView()
        configureHeadline()
        configureSubtitle()
        configureActionButton()
        configureSecureContentView()
    }

    // MARK: - Private

    private func configureImageView() {
        imageView.image = viewModel?.image
        imageView.pinHeightToScaleAspectFit()
    }

    private func configureHeadline() {
        headline.attributedText = viewModel?.title.styledAs(.display)
        headline.layoutMargins = .init(top: .space_12, left: .space_24, bottom: .zero, right: .space_24)
    }

    private func configureSubtitle() {
        subtitle.attributedText = viewModel?.info.styledAs(.subheader_1)
        subtitle.layoutMargins = .init(top: .space_12, left: .space_24, bottom: .space_40, right: .space_24)
    }
    
    private func configureActionButton() {
        actionButton.title = viewModel?.navigationButtonTitle
        actionButton.style = .primary
        actionButton.action = { [weak self] in
            self?.viewModel?.showNextScene()
        }
    }
    
    private func configureSecureContentView() {
        secureContentView.titleAttributedString = viewModel?.secureTitle.styledAs(.header_3)
        secureContentView.bodyAttributedString = viewModel?.secureText.styledAs(.body).colored(.onBackground70)
        secureContentView.contentView?.backgroundColor = viewModel?.backgroundColor
        secureContentView.layoutMargins = .init(top: .space_40, left: .space_24, bottom: .space_50, right: .space_24)
    }
}


// MARK: - StoryboardInstantiating

extension StartOnboardingViewController: StoryboardInstantiating {
    public static var storyboardName: String {
        return UIConstants.Storyboard.Onboarding
    }
}
