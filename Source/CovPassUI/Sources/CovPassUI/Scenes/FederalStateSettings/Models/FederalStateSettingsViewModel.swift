//
//  FederalStateSettingsViewModelProtocol.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import CovPassCommon
import PromiseKit

open class FederalStateSettingsViewModel: FederalStateSettingsViewModelProtocol {
    private let router: FederalStateSettingsRouterProtocol
    private var userDefaults: Persistence

    public var title: String = Texts.title
    public var copyText: String = Texts.copyText
    public var inputTitle: String = Texts.inputTitle

    public var inputValue: String {
        userDefaults.stateSelection.isEmpty ? "" : "DE_\(userDefaults.stateSelection)".localized(bundle: .main)
    }

    public init(router: FederalStateSettingsRouterProtocol, userDefaults: Persistence) {
        self.router = router
        self.userDefaults = userDefaults
    }

    public func showFederalStateSelection() -> Promise<Void> {
        router.showFederalStateSelection()
    }
}

extension FederalStateSettingsViewModel {
    public enum Texts {
        public static let title = "infschg_settings_federal_state_page_title".localized(bundle: .main)
        public static let copyText = "infschg_settings_federal_state_page_copy".localized(bundle: .main)
        public static let inputTitle = "infschg_settings_federal_state_page_tag".localized(bundle: .main)
    }
}
