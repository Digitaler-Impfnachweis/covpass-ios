//
//  StateSelectionViewModel.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import Foundation
import PromiseKit

private enum Constants {
    enum Keys {
        static let pageTitle = "infschg_module_choose_federal_state_title".localized(bundle: .main)
    }

    public enum Accessibility {
        static let openingAnnounce = "accessibility_checkapp_popup_choose_federal_state_announce".localized(bundle: .main)
        static let choosenState = "accessibility_checkapp_popup_choose_federal_state_announce_when_chosen".localized(bundle: .main)
        static let closingAnnounce = "accessibility_checkapp_popup_choose_federal_state_announce".localized(bundle: .main)
    }
}

public class StateSelectionViewModel: StateSelectionViewModelProtocol {
    // MARK: public properties

    public let pageTitle = Constants.Keys.pageTitle
    public let states = States.load.sorted(by:<)
    public let openingAnnounce: String = Constants.Accessibility.openingAnnounce
    public let closingAnnounce: String = Constants.Accessibility.closingAnnounce
    public let choosenState: String = Constants.Accessibility.choosenState

    // MARK: private properties

    private var persistence: UserDefaultsPersistence
    private var resolver: Resolver<Void>

    // MARK: lifecycle

    public init(persistence: UserDefaultsPersistence,
                resolver: Resolver<Void>) {
        self.persistence = persistence
        self.resolver = resolver
    }

    // MARK: public methods

    public func choose(state: String) {
        persistence.stateSelection = state
        resolver.fulfill_()
    }

    public func close() {
        resolver.fulfill_()
    }
}
