//
//  File.swift
//  
//
//  Created by Sebastian Maschinski on 06.05.21.
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
