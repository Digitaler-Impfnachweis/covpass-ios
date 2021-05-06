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

//    open var dataPrivacyTitle: NSAttributedString {
//        NSMutableAttributedString(string: "vaccination_data_privacy_disclaimer".localized).addLink(url: "https://www.digitaler-impfnachweis-app.de/webviews/client-app/privacy/", in: "Datenschutzerklärung").styledAs(.body)
//    }

public protocol OnboardingPageViewModel {
    var delegate: ViewModelDelegate? { get set }
    var type: OnboardingPageViewModelType { get set }
    var image: UIImage? { get }
    var title: String { get }
    var info: String { get }
}
