//
//  ContainerViewModel.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import UIKit

open class ContainerViewModel: ContainerViewModelProtocol {
    public var title: String
    public var embeddedViewController: SceneFactory
    public var router: ContainerSceneRouterProtocol

    public init(title: String, embeddedViewController: SceneFactory, router: ContainerSceneRouterProtocol) {
        self.title = title
        self.embeddedViewController = embeddedViewController
        self.router = router
    }

    public func close() {
        router.dismiss()
    }
}
