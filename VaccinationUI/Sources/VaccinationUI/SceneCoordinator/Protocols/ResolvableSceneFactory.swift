//
//  ModalSceneFactory.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

import UIKit
import PromiseKit

public protocol ResolvableSceneFactory {
    associatedtype Result
    func make(resolvable: Resolver<Result>) -> UIViewController
}
