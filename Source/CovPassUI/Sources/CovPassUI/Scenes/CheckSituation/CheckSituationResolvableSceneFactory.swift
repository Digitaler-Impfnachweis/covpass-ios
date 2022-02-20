//
//  CheckSituationSceneFactory.swift
//  
//
//  Created by Fatih Karakurt on 24.01.22.
//

import PromiseKit
import UIKit
import CovPassCommon

public struct CheckSituationResolvableSceneFactory: ResolvableSceneFactory {
    
    // MARK: - Lifecycle
    private let contextType: CheckSituationViewModelContextType
    private let userDefaults: Persistence

    public init(contextType: CheckSituationViewModelContextType,
                userDefaults: Persistence) {
        self.userDefaults = userDefaults
        self.contextType = contextType
    }

    // MARK: - Methods

    public func make(resolvable: Resolver<Void>) -> UIViewController {
        let viewModel = CheckSituationViewModel(context: contextType,
                                                userDefaults: userDefaults,
                                                resolver: resolvable)
        let viewController = CheckSituationViewController(viewModel: viewModel)
        return viewController
    }
}
