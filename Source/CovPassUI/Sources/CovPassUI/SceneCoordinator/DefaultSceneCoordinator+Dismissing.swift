//
//  DefaultSceneCoordinator+Dismiss.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import UIKit

extension DefaultSceneCoordinator: SceneDismissing {
    public func pop(animated: Bool) {
        popViewController(animated: animated)
    }

    public func dismiss(animated: Bool) {
        dismissViewController(animated)
    }
}
