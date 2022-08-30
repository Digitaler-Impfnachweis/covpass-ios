//
//  SceneFactoryMock.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassUI
import UIKit

struct SceneFactoryMock: SceneFactory {
    func make() -> UIViewController {
        .init()
    }
}
