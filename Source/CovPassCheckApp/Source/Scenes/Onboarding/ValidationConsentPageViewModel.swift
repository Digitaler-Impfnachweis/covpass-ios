//
//  ValidationConsentPageViewModel.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassUI
import UIKit

class ValidationConsentPageViewModel: ConsentPageViewModel {
    // MARK: - Properties

    var router: ConsentRouterProtocol
    weak var delegate: ViewModelDelegate?
    let type: OnboardingPageViewModelType

    var toolbarState: CustomToolbarState {
        isScrolledToBottom ?
            .confirm("confirmation_fourth_onboarding_page_button_title".localized) :
            .scrollAware
    }

    var image: UIImage? {
        .onboardingScreen4
    }

    var title: String? {
        "validation_fourth_onboarding_page_title".localized
    }

    var info: String? {
        "vaccination_fourth_onboarding_page_message".localized
    }

    var listItems: NSAttributedString {
        NSAttributedString.toBullets(
            ["validation_fourth_onboarding_first_list_item".localized.styledAs(.body),
             "validation_fourth_onboarding_second_list_item".localized.styledAs(.body),
             "validation_fourth_onboarding_third_list_item".localized.styledAs(.body)]
        )
    }

    var dataPrivacyTitle: NSAttributedString {
        NSMutableAttributedString(string: "app_information_title_datenschutz".localized).styledAs(.header_3)
    }

    var isScrolledToBottom: Bool = false {
        didSet {
            delegate?.viewModelDidUpdate()
        }
    }

    var showUSTerms: Bool {
        false
    }

    // MARK: - Lifecycle

    init(type: OnboardingPageViewModelType, router: ConsentRouterProtocol) {
        self.type = type
        self.router = router
    }
}
