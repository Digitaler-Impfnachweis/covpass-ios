//
//  OnboardingViewController.swift
//  
//
//  Copyright © 2021 IBM. All rights reserved.
//

import UIKit

public class OnboardingViewController: UIViewController {
    @IBOutlet var firstOnboardingPage: OnboardingLogoAndTextView!
    @IBOutlet var secondOnboardingPage: OnboardingLogoAndTextView!
    @IBOutlet var thirdOnboardingPage: OnboardingLogoAndTextView!
    @IBOutlet var primaryButtonContainer: PrimaryButtonContainer!

    public override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
    }

    private func setupViews() {
        firstOnboardingPage.textKey = "Laden Sie Ihre Bescheinigung nach der Impfung per QR Code einfach in die App"
        firstOnboardingPage.initView()

        secondOnboardingPage.textKey = "Teilen Sie bei Bedarf den Impfeintrag mit der Ärzt*in"
        secondOnboardingPage.initView()

        thirdOnboardingPage.textKey = "Den vollen Impfschutz sicher mit dem Prüfzertifikat nachweisen"
        thirdOnboardingPage.initView()
    }
}

extension OnboardingViewController: StoryboardInstantiating {
    public static var storyboardName: String {
        UIConstants.Storyboard.Onboarding
    }
}
