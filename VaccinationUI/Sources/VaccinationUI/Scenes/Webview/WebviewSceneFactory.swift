//
//  File.swift
//  
//
//  Created by Sebastian Maschinski on 06.05.21.
//

import UIKit

public struct WebviewSceneFactory: SceneFactory {
    // MARK: - Properties

    public let title: String
    public let url: URL

    // MARK: - Lifecycle

    public init(
        title: String,
        url: URL) {

        self.title = title
        self.url = url
    }

    public func make() -> UIViewController {
        let viewModel = WebviewViewModel(title: title, url: url)
        let viewController = WebviewViewController(viewModel: viewModel)

        return viewController
    }
}
