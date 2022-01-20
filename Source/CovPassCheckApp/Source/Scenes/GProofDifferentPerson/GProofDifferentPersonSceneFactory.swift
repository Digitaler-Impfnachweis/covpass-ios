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
    var gProofToken: CBORWebToken
    var testProofToken: CBORWebToken
    
    // MARK: - Lifecycle
    
    init(gProofToken: CBORWebToken,
         testProofToken: CBORWebToken) {
        self.gProofToken = gProofToken
        self.testProofToken = testProofToken
    }
    
    func make(resolvable: Resolver<GProofResult>) -> UIViewController {
        let viewModel = GProofDifferentPersonViewModel(gProofToken: gProofToken,
                                                       testProofToken: testProofToken,
                                                       resolver: resolvable)
        let viewController = GProofDifferentPersonViewController(viewModel: viewModel)
        return viewController
    }
}
