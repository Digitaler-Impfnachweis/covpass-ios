//
//  ContainerViewModelProtocol.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation

public protocol ContainerViewModelProtocol {
    // ContainerView title
    var title: String { get set }

    // Embedded ViewController in ContainerView
    var embeddedViewController: SceneFactory { get set }

    // Action to close the ContainerView
    func close()
}
