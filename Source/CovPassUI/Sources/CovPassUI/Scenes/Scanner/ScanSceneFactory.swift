//
//  ScanSceneFactory.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import PromiseKit
import UIKit

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
        return viewController
    }
}
