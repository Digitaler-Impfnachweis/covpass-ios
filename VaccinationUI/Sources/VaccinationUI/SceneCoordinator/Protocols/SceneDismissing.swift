//
//  SceneDismissing.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

import Foundation

public protocol SceneDismissing {
    func pop(animated: Bool)
}

// MARK: - Optionals

extension SceneDismissing {
    public func pop(animated: Bool = true) {
        pop(animated: animated)
    }
}
