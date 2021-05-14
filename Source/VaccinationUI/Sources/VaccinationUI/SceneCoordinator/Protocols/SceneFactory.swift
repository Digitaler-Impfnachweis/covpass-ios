//
//  SceneFactory.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import UIKit

public protocol SceneFactory {
    func make() -> UIViewController
}
