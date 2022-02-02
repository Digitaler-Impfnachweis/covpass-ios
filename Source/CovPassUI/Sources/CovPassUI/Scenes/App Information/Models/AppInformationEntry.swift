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
    public let rightTitle: String?

    public init(title: String, scene: SceneFactory, rightTitle: String? = nil) {
        self.title = title
        self.scene = scene
        self.rightTitle = rightTitle
    }
}
