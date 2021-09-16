//
//  PassConsentPageViewModel.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassUI
import UIKit

class PassConsentPageViewModel: ConsentPageViewModel {
    // MARK: - Properties

    var router: ConsentRouterProtocol
    weak var delegate: ViewModelDelegate?
    private(set) var type: OnboardingPageViewModelType

    var toolbarState: CustomToolbarState {
        isScrolledToBottom ?
            .confirm("vaccination_fourth_onboarding_page_button_title".localized) :
            .scrollAware
    }

    var image: UIImage? {
        .onboardingScreen4
    }

    var title: String? {
        "vaccination_fourth_onboarding_page_title".localized
    }

    var listItems: NSAttributedString {
        NSAttributedString.toBullets(
            ["vaccination_fourth_onboarding_page_first_list_item".localized.styledAs(.body),
             "vaccination_fourth_onboarding_page_second_list_item".localized.styledAs(.body),
             "vaccination_fourth_onboarding_page_third_list_item".localized.styledAs(.body),
             "vaccination_fourth_onboarding_page_fourth_list_item".localized.styledAs(.body)]
        )
    }

    var info: String? {
        "vaccination_fourth_onboarding_page_message".localized
    }

    var dataPrivacyTitle: NSAttributedString {
        NSMutableAttributedString(string: "app_information_title_datenschutz".localized).styledAs(.header_3)
    }

    var isScrolledToBottom: Bool = false {
        didSet {
            delegate?.viewModelDidUpdate()
        }
    }

    // MARK: - Lifecycle

    init(type: OnboardingPageViewModelType, router: ConsentRouter) {
        self.type = type
        self.router = router
    }
}
