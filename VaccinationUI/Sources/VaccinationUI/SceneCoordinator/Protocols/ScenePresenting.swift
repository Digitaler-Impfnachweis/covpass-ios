//
//  ScenePresenting.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

import PromiseKit
import UIKit

public protocol ScenePresenting {
    func asRoot(_ factory: SceneFactory)
    func push(_ factory: SceneFactory, animated: Bool)
    func present(_ factory: SceneFactory, animated: Bool)
    func present<Scene: ResolvableSceneFactory>(_ factory: Scene, animated: Bool) -> Promise<Scene.Result>
}

// MARK: - Optionals

public extension ScenePresenting {
    func push(_ factory: SceneFactory, animated: Bool = true) {
        push(factory, animated: animated)
    }

    func present(_ factory: SceneFactory, animated: Bool = true) {
        present(factory, animated: animated)
    }

    func present<Scene: ResolvableSceneFactory>(_ factory: Scene, animated: Bool = true) -> Promise<Scene.Result> {
        present(factory, animated: animated)
    }
}
