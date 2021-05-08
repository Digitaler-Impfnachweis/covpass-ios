//
//  ModalSceneFactory.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

import PromiseKit
import UIKit

public protocol ResolvableSceneFactory {
    associatedtype Result
    func make(resolvable: Resolver<Result>) -> UIViewController
}
