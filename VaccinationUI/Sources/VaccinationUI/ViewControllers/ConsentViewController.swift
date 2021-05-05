//
//  ConsentViewController.swift
//  
//
//  Copyright © 2021 IBM. All rights reserved.
//

import UIKit

class ConsentViewController: OnboardingPageViewController {
    @IBOutlet var termsCheckbox: CheckboxView!
    @IBOutlet var dataPrivacyCheckbox: CheckboxView!

    override func viewDidLoad() {
        super.viewDidLoad()

        configureCheckboxes()
    }

    // MARK: - Private

    private func configureCheckboxes() {
        termsCheckbox.textView.text = inputViewModel.termsTitle
        dataPrivacyCheckbox.textView.text = inputViewModel.dataPrivacyTitle
    }
}
