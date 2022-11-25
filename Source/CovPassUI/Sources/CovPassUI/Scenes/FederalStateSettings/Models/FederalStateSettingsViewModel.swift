//
//  FederalStateSettingsViewModelProtocol.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import Foundation
import PromiseKit

open class FederalStateSettingsViewModel: FederalStateSettingsViewModelProtocol {
    private let router: FederalStateSettingsRouterProtocol
    private let userDefaults: Persistence
    private let certificateHolderStatus: CertificateHolderStatusModelProtocol

    public let title: String = Texts.title
    public let copy1Text: String = Texts.copy1Text
    public var copy2Text: String? {
        guard let date = certificateHolderStatus.latestMaskRuleDate(for: userDefaults.stateSelection) else {
            return nil
        }
        return String(format: Texts.copy2Text, DateUtils.displayDateFormatter.string(from: date))
    }

    public let inputTitle: String = Texts.inputTitle
    public let openingAnnounce: String = Accessibility.openingAnnounce
    public let closingAnnounce: String = Accessibility.closingAnnounce
    public var choosenState: String { String(format: Accessibility.choosenState, inputValue) }

    public var inputValue: String {
        userDefaults.stateSelection.isEmpty ? "" : "DE_\(userDefaults.stateSelection)".localized(bundle: .main)
    }

    public init(router: FederalStateSettingsRouterProtocol, userDefaults: Persistence, certificateHolderStatus: CertificateHolderStatusModelProtocol) {
        self.router = router
        self.userDefaults = userDefaults
        self.certificateHolderStatus = certificateHolderStatus
    }

    public func showFederalStateSelection() -> Promise<Void> {
        router.showFederalStateSelection()
    }
}

public extension FederalStateSettingsViewModel {
    enum Texts {
        public static let title = "infschg_settings_federal_state_page_title".localized(bundle: .main)
        public static let copy1Text = "infschg_settings_federal_state_page_copy_1".localized(bundle: .main)
        public static let copy2Text = "infschg_settings_federal_state_page_copy_2".localized(bundle: .main)
        public static let inputTitle = "infschg_settings_federal_state_page_tag".localized(bundle: .main)
    }

    enum Accessibility {
        static let openingAnnounce = "accessibility_checkapp_popup_choose_federal_state_announce".localized(bundle: .main)
        static let choosenState = "accessibility_checkapp_popup_choose_federal_state_announce_when_chosen".localized(bundle: .main)
        static let closingAnnounce = "accessibility_checkapp_popup_choose_federal_state_announce".localized(bundle: .main)
    }
}
