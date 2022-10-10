//
//  StateSelectionViewModel.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import CovPassCommon
import PromiseKit

private enum Constants {
    enum Keys {
        static let pageTitle = "infschg_module_choose_federal_state_title".localized(bundle: .main)
    }
}

public class StateSelectionViewModel: StateSelectionViewModelProtocol {
    
    // MARK: public properties

    public var pageTitle = Constants.Keys.pageTitle
    public var states = States.load.sorted(by:<)
    
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
