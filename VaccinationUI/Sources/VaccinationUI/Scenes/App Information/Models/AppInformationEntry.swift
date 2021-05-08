//
//  AppInformationEntry.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
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
