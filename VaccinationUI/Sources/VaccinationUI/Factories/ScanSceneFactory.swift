//
//  ScanSceneFactory.swift
//  
//
//  Created by Sebastian Maschinski on 03.05.21.
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
