//
//  SceneDismissing.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

import Foundation

public protocol SceneDismissing {
    /// pops the current top viewcontroller from navigation stack
    func pop(animated: Bool)

    /// dismiss the presented top viewcontroller
    func dimiss(animated: Bool)
}

// MARK: - Optionals

public extension SceneDismissing {
    func pop(animated: Bool = true) {
        pop(animated: animated)
    }

    func dimiss(animated: Bool = true) {
        dimiss(animated: animated)
    }
}
