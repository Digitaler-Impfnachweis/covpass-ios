//
//  ScenePresenting.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

import UIKit
import PromiseKit

public protocol ScenePresenting {
    func asRoot(_ factory: SceneFactory)
    func push(_ factory: SceneFactory, animated: Bool)
    func present(_ factory: SceneFactory, animated: Bool)
    func present<Scene: ResolvableSceneFactory>(_ factory: Scene, animated: Bool) -> Promise<Scene.Result>
}

// MARK: - Optionals

extension ScenePresenting {
    public func push(_ factory: SceneFactory, animated: Bool = true) {
        push(factory, animated: animated)
    }

    public func present(_ factory: SceneFactory, animated: Bool = true) {
        present(factory, animated: animated)
    }

    public func present<Scene: ResolvableSceneFactory>(_ factory: Scene, animated: Bool = true) -> Promise<Scene.Result> {
        present(factory, animated: animated)
    }
}
