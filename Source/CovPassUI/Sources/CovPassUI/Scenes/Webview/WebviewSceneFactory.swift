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

    // MARK: - Lifecycle

    public init(
        title: String,
        url: URL,
        closeButtonShown: Bool = false
    ) {
        self.title = title
        self.url = url
        self.closeButtonShown = closeButtonShown
    }

    public func make() -> UIViewController {
        let viewModel = WebviewViewModel(title: title, url: url, closeButtonShown: closeButtonShown)
        let viewController = WebviewViewController(viewModel: viewModel)

        return viewController
    }
}
