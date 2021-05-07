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

    private let cameraAccessProvider: CameraAccessProviderProtocol

    public init(cameraAccessProvider: CameraAccessProviderProtocol) {
        self.cameraAccessProvider = cameraAccessProvider
    }

    // MARK: - Methods

    public func make(resolvable: Resolver<ScanResult>) -> UIViewController {
        let viewModel = ScanViewModel(
            cameraAccessProvider: cameraAccessProvider,
            resolvable: resolvable
        )
        let viewController = ScanViewController(viewModel: viewModel)
        viewController.modalPresentationStyle = .fullScreen
        return viewController
    }
}
