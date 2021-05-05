//
//  OnboardingPageViewModel.swift
//  
//
//  Copyright © 2021 IBM. All rights reserved.
//

import UIKit

public enum OnboardingPageViewModelType: CaseIterable {
    case page1
    case page2
    case page3
    case page4
}

open class OnboardingPageViewModel: BaseViewModel {
    public var type: OnboardingPageViewModelType

    public init(type: OnboardingPageViewModelType) {
        self.type = type
    }

    open var image: UIImage? {
        switch type {
        case .page1:
            return .onboardingScreen1
        case .page2:
            return .onboardingScreen2
        case .page3:
            return .onboardingScreen3
        case .page4:
            return .onboardingScreen4
        }
    }

    open var title: String {
        switch type {
        case .page1:
            return "vaccination_first_onboarding_page_title".localized
        case .page2:
            return "vaccination_second_onboarding_page_title".localized
        case .page3:
            return "vaccination_third_onboarding_page_title".localized
        case .page4:
            return "Zustimmung für die Nutzung"
        }
    }

    open var info: String {
        switch type {
        case .page1:
            return "vaccination_first_onboarding_page_message".localized
        case .page2:
            return "vaccination_second_onboarding_page_message".localized
        case .page3:
            return "vaccination_third_onboarding_page_message".localized
        case .page4:
            return "Um die App zu nutzen, müssen Sie bestätigen, dass Sie den AGBs zustimmen und die Datenschuterklärung zur Kenntnis genommen haben."
        }
    }

    open var dataPrivacyTitle: NSAttributedString {
        NSMutableAttributedString(string: "Ich habe die Datenschutzerklärung zur Kenntnis genommen.").addLink(url: "https://www.coronawarn.app/assets/documents/cwa-privacy-notice-de.pdf", in: "Datenschutzerklärung").styledAs(.body)
    }

    // MARK: - Settings

    public var backgroundColor: UIColor { .backgroundPrimary }
}

