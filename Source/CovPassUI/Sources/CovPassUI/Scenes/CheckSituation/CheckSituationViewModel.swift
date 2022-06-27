//
//  CheckSituationViewModel.swift
//  
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import UIKit
import CovPassCommon
import PromiseKit

private enum Constants {
    enum Keys {
        enum General {
            static let navBarTitle = "app_information_title_local_rules".localized(bundle: .main)
            static let pageTitle = "check_context_onboarding_title".localized(bundle: .main)
            static let newBadgeText = "check_context_onboarding_tag".localized(bundle: .main)
            static let travelRulesTitle = "check_context_onboarding_option1_title".localized(bundle: .main)
            static let travelRulesDescription = "check_context_onboarding_option1_subtitle".localized(bundle: .main)
            static let domesticRulesTitle = "check_context_onboarding_option2_title".localized(bundle: .main)
            static let domesticRulesDescription = "check_context_onboarding_option2_subtitle".localized(bundle: .main)
            static let footerText = "check_context_onboarding_footnote".localized(bundle: .main)
            static let doneButtonTitle = "check_context_onboarding_button".localized(bundle: .main)
        }
        enum Information {
            static let navBarTitle = "accessibility_dialog_local_rulecheck_title_announce".localized(bundle: .main)
            static let pageTitle = "dialog_local_rulecheck_title".localized(bundle: .main)
            static let newBadgeText = "check_context_onboarding_tag".localized(bundle: .main)
            static let travelRulesTitle = "check_context_onboarding_option1_title".localized(bundle: .main)
            static let travelRulesDescription = "check_context_onboarding_option1_subtitle".localized(bundle: .main)
            static let domesticRulesTitle = "check_context_onboarding_option2_title".localized(bundle: .main)
            static let domesticRulesDescription = "check_context_onboarding_option2_subtitle".localized(bundle: .main)
            static let footerText = "dialog_local_rulecheck_copy".localized(bundle: .main)
            static let doneButtonTitle = "dialog_local_rulecheck_button".localized(bundle: .main)
            static let subTitleText = "dialog_local_rulecheck_subtitle".localized(bundle: .main)
        }
    }
    enum Images {
        static let pageImage = UIImage.illustration4
    }
    enum Accessibility {
        enum General {
            static let onboardingOpen = "accessibility_check_context_onboarding_announce_open".localized(bundle: .main)
            static let onboardingClose = "accessibility_check_context_onboarding_announce_close".localized(bundle: .main)
            static let onboardingImageDescription = "check_context_onboarding_image".localized(bundle: .main)
        }
        enum Information {
            static let onboardingOpen = "accessibility_dialog_local_rulecheck_title_announce".localized(bundle: .main)
            static let onboardingClose = "accessibility_check_context_onboarding_announce_close".localized(bundle: .main)
            static let onboardingImageDescription = "dialog_local_rulecheck_image".localized(bundle: .main)
        }
    }
}

public class CheckSituationViewModel: CheckSituationViewModelProtocol {

    // MARK: - Public/Protocol properties
    var navBarTitle: String = Constants.Keys.General.navBarTitle
    var pageTitle: String = Constants.Keys.General.pageTitle
    var newBadgeText: String = Constants.Keys.General.newBadgeText
    var pageImage: UIImage = Constants.Images.pageImage
    var travelRulesTitle: String = Constants.Keys.General.travelRulesTitle
    var travelRulesDescription: String = Constants.Keys.General.travelRulesDescription
    var domesticRulesTitle: String = Constants.Keys.General.domesticRulesTitle
    var domesticRulesDescription: String = Constants.Keys.General.domesticRulesDescription
    var footerText: String = Constants.Keys.General.footerText
    var subTitleText: String = Constants.Keys.Information.subTitleText
    var doneButtonTitle: String = Constants.Keys.General.doneButtonTitle
    var onboardingOpen: String = Constants.Accessibility.General.onboardingOpen
    var onboardingClose: String = Constants.Accessibility.General.onboardingClose
    var onboardingImageDescription: String = Constants.Accessibility.General.onboardingImageDescription
    var pageTitleIsHidden: Bool = false
    var newBadgeIconIsHidden: Bool = false
    var pageImageIsHidden: Bool = false
    var selectionIsHidden: Bool = false
    var subTitleIsHidden: Bool = true
    var descriptionTextIsTop: Bool = false
    var buttonIsHidden: Bool = false
    var selectedRule: DCCCertLogic.LogicType {
        get {
            userDefaults.selectedLogicType 
        }
        set {
            userDefaults.selectedLogicType = newValue
            DispatchQueue.main.async {
                self.delegate?.viewModelDidUpdate()
            }
        }
    }
    var delegate: ViewModelDelegate?
    var context: CheckSituationViewModelContextType {
        didSet {
            changeContext()
        }
    }
    
    // MARK: - Private properties
    private let resolver: Resolver<Void>?
    private var userDefaults: Persistence

    init (context: CheckSituationViewModelContextType,
          userDefaults: Persistence,
          resolver: Resolver<Void>?) {
        self.userDefaults = userDefaults
        self.resolver = resolver
        self.context = context
        self.changeContext()
    }
    
    func doneIsTapped() {
        resolver?.fulfill_()
    }
    
    // MARK: - Private methods
    
    private func changeContext() {
        switch context {
        case .onboarding:
            buttonIsHidden = false
            pageTitleIsHidden = false
            newBadgeIconIsHidden = false
            pageImageIsHidden = false
            descriptionTextIsTop = false
            selectionIsHidden = false
            subTitleIsHidden = true
        case .settings:
            buttonIsHidden = true
            pageTitleIsHidden = true
            newBadgeIconIsHidden = true
            pageImageIsHidden = true
            descriptionTextIsTop = true
            selectionIsHidden = false
            subTitleIsHidden = true
        case .information:
            newBadgeIconIsHidden = true
            descriptionTextIsTop = false
            buttonIsHidden = false
            pageTitleIsHidden = false
            pageImageIsHidden = false
            selectionIsHidden = true
            subTitleIsHidden = false
            navBarTitle = Constants.Keys.Information.navBarTitle
            pageTitle = Constants.Keys.Information.pageTitle
            newBadgeText = Constants.Keys.Information.newBadgeText
            pageImage = Constants.Images.pageImage
            travelRulesTitle = Constants.Keys.Information.travelRulesTitle
            travelRulesDescription = Constants.Keys.Information.travelRulesDescription
            domesticRulesTitle = Constants.Keys.Information.domesticRulesTitle
            domesticRulesDescription = Constants.Keys.Information.domesticRulesDescription
            footerText = Constants.Keys.Information.footerText
            doneButtonTitle = Constants.Keys.Information.doneButtonTitle
            onboardingOpen = Constants.Accessibility.Information.onboardingOpen
            onboardingClose = Constants.Accessibility.Information.onboardingClose
            onboardingImageDescription = Constants.Accessibility.Information.onboardingImageDescription
        }
        delegate?.viewModelDidUpdate()
    }
}
