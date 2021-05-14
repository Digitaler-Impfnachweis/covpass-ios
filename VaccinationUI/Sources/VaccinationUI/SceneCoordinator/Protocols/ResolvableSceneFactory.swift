//
//  ModalSceneFactory.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import PromiseKit
import UIKit

public protocol ResolvableSceneFactory {
    associatedtype Result
    func make(resolvable: Resolver<Result>) -> UIViewController
}
