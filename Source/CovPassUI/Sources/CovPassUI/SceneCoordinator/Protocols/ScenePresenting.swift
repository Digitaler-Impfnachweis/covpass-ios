//
//  ScenePresenting.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import PromiseKit
import UIKit

public protocol ScenePresenting {
    func asRoot(_ factory: SceneFactory)
    func push(_ factory: SceneFactory, animated: Bool)
    func push<Scene: ResolvableSceneFactory>(_ factory: Scene, animated: Bool) -> Promise<Scene.Result>
    func present(_ factory: SceneFactory, animated: Bool)
    func present<Scene: ResolvableSceneFactory>(_ factory: Scene, animated: Bool) -> Promise<Scene.Result>
}

// MARK: - Optionals

public extension ScenePresenting {
    func push(_ factory: SceneFactory, animated: Bool = true) {
        push(factory, animated: animated)
    }

    func push<Scene: ResolvableSceneFactory>(_ factory: Scene, animated: Bool = true) -> Promise<Scene.Result> {
        push(factory, animated: animated)
    }

    func present(_ factory: SceneFactory, animated: Bool = true) {
        present(factory, animated: animated)
    }

    func present<Scene: ResolvableSceneFactory>(_ factory: Scene, animated: Bool = true) -> Promise<Scene.Result> {
        present(factory, animated: animated)
    }
}
