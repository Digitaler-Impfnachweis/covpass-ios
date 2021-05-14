//
//  PassConsentPageViewModel.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import UIKit
import VaccinationUI

class PassConsentPageViewModel: ConsentPageViewModel {
    // MARK: - Properties

    weak var delegate: ViewModelDelegate?
    private(set) var type: OnboardingPageViewModelType

    var toolbarState: CustomToolbarState {
        isGranted ?
            .confirm("confirmation_fourth_onboarding_page_button_title".localized) :
            .disabledWithText("confirmation_fourth_onboarding_page_button_title".localized)
    }

    var image: UIImage? {
        .onboardingScreen4
    }

    var title: String? {
        "vaccination_fourth_onboarding_page_title".localized
    }

    var info: String? {
        "vaccination_fourth_onboarding_page_message".localized
    }

    var dataPrivacyTitle: NSAttributedString {
        NSMutableAttributedString(string: "fourth_onboarding_page_second_selection".localized).addLink(url: "https://www.digitaler-impfnachweis-app.de/webviews/client-app/privacy/", in: "Datenschutzerklärung").styledAs(.body)
    }

    var isGranted: Bool = false {
        didSet {
            delegate?.viewModelDidUpdate()
        }
    }

    // MARK: - Lifecycle

    init(type: OnboardingPageViewModelType) {
        self.type = type
    }
}
