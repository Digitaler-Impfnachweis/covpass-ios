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
    
    private let title: String
    private let url: URL
    private let closeButtonShown: Bool
    private let isToolbarShown: Bool
    private let embedInNavigationController: Bool
    private let enableDynamicFonts: Bool
    private let openingAnnounce: String
    private let closingAnnounce: String

    // MARK: - Lifecycle
    
    public init(title: String,
                url: URL,
                closeButtonShown: Bool = false,
                isToolbarShown: Bool = false,
                embedInNavigationController: Bool = false,
                enableDynamicFonts: Bool = false,
                openingAnnounce: String,
                closingAnnounce: String) {
        self.openingAnnounce = openingAnnounce
        self.closingAnnounce = closingAnnounce
        self.title = title
        self.url = url
        self.closeButtonShown = closeButtonShown
        self.isToolbarShown = isToolbarShown
        self.embedInNavigationController = embedInNavigationController
        self.enableDynamicFonts = enableDynamicFonts
    }
    
    public func make() -> UIViewController {
        let viewModel = WebviewViewModel(title: title,
                                         url: url,
                                         closeButtonShown: closeButtonShown,
                                         isToolbarShown: isToolbarShown,
                                         enableDynamicFonts: enableDynamicFonts,
                                         openingAnnounce: openingAnnounce,
                                         closingAnnounce: closingAnnounce)
        let viewController = WebviewViewController(viewModel: viewModel)
        return embedInNavigationController ? UINavigationController(rootViewController: viewController) : viewController
    }
}
