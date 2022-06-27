//
//  File.swift
//  
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassUI

extension AppInformationEntry {
    static func mock() -> AppInformationEntry {
        .init(title: "", scene: SceneFactoryMock())
    }
}
