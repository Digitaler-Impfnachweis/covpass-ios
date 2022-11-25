//
//  SelectStateOnboardingViewModel.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import PromiseKit
import UIKit

public extension SelectStateOnboardingViewModel {
    enum Texts {
        public static let title = "infschg_popup_choose_federal_state_title".localized(bundle: .main)
        public static let copyText = "infschg_popup_choose_federal_state_copy_1".localized(bundle: .main)
        public static let inputTitle = "infschg_popup_choose_federal_state_tag".localized(bundle: .main)
        public static let inputValue = "infschg_popup_choose_federal_state_box_content".localized(bundle: .main)
        public static let copy2Text = "infschg_popup_choose_federal_state_copy_2".localized(bundle: .main)
        public static let copy3Text = "infschg_popup_choose_federal_state_copy_3".localized(bundle: .main)
    }

    enum Accessibility {
        static let openingAnnounce = "accessibility_checkapp_popup_choose_federal_state_announce".localized(bundle: .main)
        static let choosenState = "accessibility_checkapp_popup_choose_federal_state_announce_when_chosen".localized(bundle: .main)
        static let closingAnnounce = "accessibility_checkapp_popup_choose_federal_state_announce".localized(bundle: .main)
    }
}

open class SelectStateOnboardingViewModel: SelectStateOnboardingViewModelProtocol {
    private let router: SelectStateOnboardingViewRouterProtocol
    private var userDefaults: Persistence
    private let certificateHolderStatus: CertificateHolderStatusModelProtocol
    private let resolver: Resolver<Void>

    public let title: String = Texts.title
    public let copyText: String = Texts.copyText
    public let copy2Text: String = Texts.copy2Text
    public var copy3Text: String? {
        guard let date = certificateHolderStatus.latestMaskRuleDate(for: userDefaults.stateSelection) else {
            return nil
        }
        return String(format: Texts.copy3Text, DateUtils.displayDateFormatter.string(from: date))
    }

    public let inputTitle: String = Texts.inputTitle
    public let image: UIImage = .illustrationImpfschutzgesetz
    public let openingAnnounce: String = Accessibility.openingAnnounce
    public let closingAnnounce: String = Accessibility.closingAnnounce
    public var choosenState: String { String(format: Accessibility.choosenState, inputValue) }

    public var inputValue: String {
        let federalState = userDefaults.stateSelection.isEmpty ? "" : "DE_\(userDefaults.stateSelection)".localized(bundle: .main)
        return String(format: Texts.inputValue, federalState)
    }

    public init(resolver: Resolver<Void>, router: SelectStateOnboardingViewRouterProtocol, userDefaults: Persistence, certificateHolderStatus: CertificateHolderStatusModelProtocol) {
        self.resolver = resolver
        self.router = router
        self.userDefaults = userDefaults
        self.certificateHolderStatus = certificateHolderStatus
    }

    public func showFederalStateSelection() -> Promise<Void> {
        router.showFederalStateSelection()
    }

    public func close() {
        resolver.fulfill_()
    }
}
