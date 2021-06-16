//
//  SceneCoordinator+Presenting.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import PromiseKit
import UIKit

extension DefaultSceneCoordinator: ScenePresenting {
    public func asRoot(_ factory: SceneFactory) {
        asRootViewController(
            factory.make()
        )
    }

    public func push(_ factory: SceneFactory, animated: Bool) {
        push(
            viewController: factory.make(),
            animated: animated
        )
    }

    public func push<Scene: ResolvableSceneFactory>(_ factory: Scene, animated: Bool) -> Promise<Scene.Result> {
        let (promise, resolver) = Promise<Scene.Result>.pending()
        return push(
            viewController: factory.make(resolvable: resolver),
            promise: promise,
            animated: animated
        )
    }

    public func present(_ factory: SceneFactory, animated: Bool) {
        present(
            viewController: factory.make(),
            animated: animated
        )
    }

    public func present<Scene: ResolvableSceneFactory>(_ factory: Scene, animated: Bool) -> Promise<Scene.Result> {
        let (promise, resolver) = Promise<Scene.Result>.pending()
        return present(
            viewController: factory.make(resolvable: resolver),
            promise: promise,
            animated: animated
        )
    }
}
