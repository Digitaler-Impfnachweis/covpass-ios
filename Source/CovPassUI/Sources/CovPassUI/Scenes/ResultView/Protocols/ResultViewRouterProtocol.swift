//
//  ResultViewRouterProtocol.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import PromiseKit

public protocol ResultViewRouterProtocol: RouterProtocol {
    func showPDFExport(for token: ExtendedCBORWebToken) -> Promise<Void>
}

public class ResultViewRouter: ResultViewRouterProtocol {
    // MARK: - Properties

    public let sceneCoordinator: SceneCoordinator

    // MARK: - Lifecycle

    public init(sceneCoordinator: SceneCoordinator) {
        self.sceneCoordinator = sceneCoordinator
    }

    // MARK: - Methods

    public func showPDFExport(for token: ExtendedCBORWebToken) -> Promise<Void> {
        sceneCoordinator.present(
            PDFExportSceneFactory(token: token)
        )
    }
}
