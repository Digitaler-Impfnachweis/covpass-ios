//
//  WebviewSceneFactory.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import UIKit

public struct WebviewSceneFactory: SceneFactory {
    // MARK: - Properties

    public let title: String
    public let url: URL
    public let closeButtonShown: Bool
    public let isToolbarShown: Bool
    public let embedInNavigationController: Bool

    // MARK: - Lifecycle

    public init(
        title: String,
        url: URL,
        closeButtonShown: Bool = false,
        isToolbarShown: Bool = false,
        embedInNavigationController: Bool = false
    ) {
        self.title = title
        self.url = url
        self.closeButtonShown = closeButtonShown
        self.isToolbarShown = isToolbarShown
        self.embedInNavigationController = embedInNavigationController
    }

    public func make() -> UIViewController {
        let viewModel = WebviewViewModel(title: title, url: url, closeButtonShown: closeButtonShown, isToolbarShown: isToolbarShown)
        let viewController = WebviewViewController(viewModel: viewModel)
        return embedInNavigationController ? UINavigationController(rootViewController: viewController) : viewController
    }
}
