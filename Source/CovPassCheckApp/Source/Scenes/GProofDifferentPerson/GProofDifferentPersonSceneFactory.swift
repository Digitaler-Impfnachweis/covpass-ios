//
//  GProofDifferentPersonSceneFactory.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassUI
import UIKit
import CovPassCommon
import PromiseKit

struct GProofDifferentPersonSceneFactory: ResolvableSceneFactory {
    
    // MARK: - Properties
    var firstResultCert: CBORWebToken
    var secondResultCert: CBORWebToken
    
    // MARK: - Lifecycle
    
    init(firstResultCert: CBORWebToken,
         secondResultCert: CBORWebToken) {
        self.firstResultCert = firstResultCert
        self.secondResultCert = secondResultCert
    }
    
    func make(resolvable: Resolver<GProofResult>) -> UIViewController {
        let viewModel = GProofDifferentPersonViewModel(firstResultCert: firstResultCert,
                                                       secondResultCert: secondResultCert,
                                                       resolver: resolvable)
        let viewController = GProofDifferentPersonViewController(viewModel: viewModel)
        return viewController
    }
}
