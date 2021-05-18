//
//  SceneFactoryMock.swift
//  
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassUI
import PromiseKit
import UIKit

struct SceneFactoryMock: SceneFactory {
    var viewController: UIViewController?

    func make() -> UIViewController {
        guard let viewController = self.viewController else {
            fatalError("ViewController must not be nil")
        }
        return viewController
    }
}
