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

public protocol CheckSituationViewModelProtocol {
    var navBarTitle: String { get }
    var pageTitle: String { get }
    var situationChcekTitleLabelHidden: Bool { get }
    var situationChcekTitle: String { get }
    var newBadgeText: String { get }
    var pageImage: UIImage { get }
    var travelRulesTitle: String { get }
    var travelRulesDescription: String { get }
    var domesticRulesTitle: String { get }
    var domesticRulesDescription: String { get }
    var subTitleText: String { get }
    var footerText: String { get }
    var doneButtonTitle: String { get }
    var offlineRevocationTitle: String { get }
    var offlineRevocationDescription: String { get }
    var offlineRevocationSwitchTitle: String { get }
    var pageTitleIsHidden: Bool { get }
    var newBadgeIconIsHidden: Bool { get }
    var pageImageIsHidden: Bool { get }
    var selectionIsHidden: Bool { get }
    var subTitleIsHidden: Bool { get }
    var offlineRevocationIsHidden: Bool { get }
    var offlineRevocationIsEnabled: Bool { get }
    var descriptionTextIsTop: Bool { get }
    var hStackViewIsHidden: Bool { get }
    var buttonIsHidden: Bool { get set }
    var onboardingOpen: String { get }
    var onboardingClose: String { get }
    var onboardingImageDescription: String { get }
    var selectedRule: DCCCertLogic.LogicType { get set }
    var delegate: ViewModelDelegate? { get set }
    var context: CheckSituationViewModelContextType { get set }
    
    // MARK: Update related properties
    var updateContextHidden: Bool { get }
    var offlineModusButton: String  { get }
    var loadingHintTitle: String  { get }
    var cancelButtonTitle: String  { get }
    var listTitle: String  { get }
    var downloadStateHintTitle: String  { get }
    var downloadStateHintIcon: UIImage  { get }
    var downloadStateHintColor: UIColor { get }
    var downloadStateTextColor: UIColor  { get }
    var entryRulesTitle: String { get }
    var entryRulesSubtitle: String  { get }
    var domesticRulesUpdateTitle: String  { get }
    var domesticRulesUpdateSubtitle: String { get }
    var valueSetsTitle: String  { get }
    var valueSetsSubtitle: String  { get }
    var certificateProviderTitle: String  { get }
    var certificateProviderSubtitle: String  { get }
    var countryListTitle: String  { get }
    var countryListSubtitle: String  { get }
    var authorityListTitle: String  { get }
    var authorityListSubtitle: String  { get }
    var isLoading: Bool { get }
    
    func doneIsTapped()
    func toggleOfflineRevocation()
    func refresh()
    func cancel()
}
