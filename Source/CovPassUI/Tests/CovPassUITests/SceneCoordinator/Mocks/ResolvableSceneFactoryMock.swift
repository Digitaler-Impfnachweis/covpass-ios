//
//  ResolvableSceneFactoryMock.swift
//  
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassUI
import PromiseKit
import UIKit

class ResolvableSceneFactoryMock: ResolvableSceneFactory {
    let viewController: UIViewController
    var resolver: Resolver<String>?

    init(viewController: UIViewController) {
        self.viewController = viewController
    }

    func make(resolvable: Resolver<String>) -> UIViewController {
        resolver = resolvable
        return viewController
    }
}
