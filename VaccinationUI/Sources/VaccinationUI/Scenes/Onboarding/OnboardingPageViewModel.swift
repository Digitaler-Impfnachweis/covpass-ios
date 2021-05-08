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

public protocol OnboardingPageViewModel {
    var delegate: ViewModelDelegate? { get set }
    var type: OnboardingPageViewModelType { get }
    var toolbarState: CustomToolbarState { get }
    var image: UIImage? { get }
    var title: String? { get }
    var info: String? { get }
}

public protocol ConsentPageViewModel: OnboardingPageViewModel {
    var dataPrivacyTitle: NSAttributedString { get }
    var isGranted: Bool { get set }
}
