//
//  DifferentPersonSceneFactory.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassUI
import UIKit
import CovPassCommon
import PromiseKit

enum DifferentPersonResult {
    case ignore
    case startover
}

struct DifferentPersonSceneFactory: ResolvableSceneFactory {
    
    // MARK: - Properties
    var firstResultCert: CBORWebToken
    var secondResultCert: CBORWebToken
    
    // MARK: - Lifecycle
    
    init(firstResultCert: CBORWebToken,
         secondResultCert: CBORWebToken) {
        self.firstResultCert = firstResultCert
        self.secondResultCert = secondResultCert
    }
    
    func make(resolvable: Resolver<DifferentPersonResult>) -> UIViewController {
        let countdownTimerModel = CountdownTimerModel(
            dismissAfterSeconds: 120,
            countdownDuration: 60
        )
        let viewModel = DifferentPersonViewModel(firstResultCert: firstResultCert,
                                                       secondResultCert: secondResultCert,
                                                       resolver: resolvable,
                                                       countdownTimerModel: countdownTimerModel)
        let viewController = DifferentPersonViewController(viewModel: viewModel)
        return viewController
    }
}
