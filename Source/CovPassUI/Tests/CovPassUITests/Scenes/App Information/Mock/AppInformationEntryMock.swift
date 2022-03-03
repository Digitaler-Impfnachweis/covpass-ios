//
//  File.swift
//  
//
//  Created by Thomas Kuleßa on 09.02.22.
//

import CovPassUI

extension AppInformationEntry {
    static func mock() -> AppInformationEntry {
        .init(title: "", scene: SceneFactoryMock())
    }
}
