//
//  ScanSceneFactory.swift
//  
//
//  Copyright © 2021 IBM. All rights reserved.
//

import UIKit
import PromiseKit

public struct ScanSceneFactory: ResolvableSceneFactory {
    // MARK: - Lifecycle

    public init() {}

    // MARK: - Methods

    public func make(resolvable: Resolver<ScanResult>) -> UIViewController {
        let viewModel = ScanPopupViewModel(resolvable: resolvable)
        let viewController = ScanPopupViewController.createFromStoryboard()
        viewController.viewModel = viewModel
        return viewController
    }
}
