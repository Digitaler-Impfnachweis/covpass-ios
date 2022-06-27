//
//  CheckSituationViewModelProtocol.swift
//  
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import UIKit
import CovPassCommon

public enum CheckSituationViewModelContextType {
    case onboarding, settings, information
}

protocol CheckSituationViewModelProtocol {
    var navBarTitle: String { get }
    var pageTitle: String { get }
    var newBadgeText: String { get }
    var pageImage: UIImage { get }
    var travelRulesTitle: String { get }
    var travelRulesDescription: String { get }
    var domesticRulesTitle: String { get }
    var domesticRulesDescription: String { get }
    var subTitleText: String { get }
    var footerText: String { get }
    var doneButtonTitle: String { get }
    var pageTitleIsHidden: Bool { get }
    var newBadgeIconIsHidden: Bool { get }
    var pageImageIsHidden: Bool { get }
    var selectionIsHidden: Bool { get }
    var subTitleIsHidden: Bool { get }
    var descriptionTextIsTop: Bool { get }
    var buttonIsHidden: Bool { get set }
    var onboardingOpen: String { get }
    var onboardingClose: String { get }
    var onboardingImageDescription: String { get }
    var selectedRule: DCCCertLogic.LogicType { get set }
    var delegate: ViewModelDelegate? { get set }
    var context: CheckSituationViewModelContextType { get set }
    func doneIsTapped()
}
