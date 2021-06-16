//
//  AppInformationEntry.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation

public struct AppInformationEntry {
    public let title: String
    public let scene: SceneFactory

    public init(title: String, scene: SceneFactory) {
        self.title = title
        self.scene = scene
    }
}
