//
//  AnnouncementRouter.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation

public class DataPrivacyRouter: RouterProtocol {
    // MARK: - Properties

    public let sceneCoordinator: SceneCoordinator

    // MARK: - Lifecycle

    public init(sceneCoordinator: SceneCoordinator) {
        self.sceneCoordinator = sceneCoordinator
    }
}
