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
}

public protocol OnboardingPageViewModel {
    var delegate: ViewModelDelegate? { get set }
    var type: OnboardingPageViewModelType { get set }
    var image: UIImage? { get }
    var title: String { get }
    var info: String { get }
}
