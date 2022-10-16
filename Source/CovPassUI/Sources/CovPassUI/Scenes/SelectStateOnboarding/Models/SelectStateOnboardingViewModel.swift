//
//  SelectStateOnboardingViewModel.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import PromiseKit
import UIKit

extension SelectStateOnboardingViewModel {
    public enum Texts {
        public static let title = "infschg_popup_choose_federal_state_title".localized(bundle: .main)
        public static let copyText = "infschg_popup_choose_federal_state_copy_1".localized(bundle: .main)
        public static let inputTitle = "infschg_popup_choose_federal_state_tag".localized(bundle: .main)
        public static let inputValue = "infschg_popup_choose_federal_state_box_content".localized(bundle: .main)
        public static let copy2Text = "infschg_popup_choose_federal_state_copy_2".localized(bundle: .main)
    }
}

open class SelectStateOnboardingViewModel: SelectStateOnboardingViewModelProtocol {
    private let router: SelectStateOnboardingViewRouterProtocol
    private var userDefaults: Persistence
    private let resolver: Resolver<Void>

    public var title: String = Texts.title
    public var copyText: String = Texts.copyText
    public var copy2Text: String = Texts.copy2Text
    public var inputTitle: String = Texts.inputTitle
    public var image: UIImage = .illustrationImpfschutzgesetz

    public var inputValue: String {
        let federalState = userDefaults.stateSelection.isEmpty ? "" : "DE_\(userDefaults.stateSelection)".localized(bundle: .main)
        return String(format: Texts.inputValue, federalState)
    }

    public init(resolver: Resolver<Void>, router: SelectStateOnboardingViewRouterProtocol, userDefaults: Persistence) {
        self.resolver = resolver
        self.router = router
        self.userDefaults = userDefaults
    }

    public func showFederalStateSelection() -> Promise<Void> {
        router.showFederalStateSelection()
    }
    
    public func close() {
        resolver.fulfill_()
    }
}

