//
//  DefaultSceneCoordinator+Dismiss.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

import UIKit

extension DefaultSceneCoordinator: SceneDismissing {
    public func pop(animated: Bool) {
        popViewController(animated: animated)
    }
}
