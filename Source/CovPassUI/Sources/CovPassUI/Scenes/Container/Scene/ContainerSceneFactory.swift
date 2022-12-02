//
//  ContainerSceneFactory.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import UIKit

public struct ContainerSceneFactory: SceneFactory {
    private let title: String
    private let embeddedViewController: SceneFactory
    private let sceneCoordinator: SceneCoordinator

    public init(
        title: String,
        embeddedViewController: SceneFactory,
        sceneCoordinator: SceneCoordinator
    ) {
        self.title = title
        self.embeddedViewController = embeddedViewController
        self.sceneCoordinator = sceneCoordinator
    }

    public func make() -> UIViewController {
        ContainerViewController(
            viewModel: ContainerViewModel(
                title: title,
                embeddedViewController: embeddedViewController,
                router: ContainerSceneRouter(sceneCoordinator: sceneCoordinator)
            )
        )
    }
}
