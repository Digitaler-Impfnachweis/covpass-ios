//
//  PDFExportSceneFactory.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import PromiseKit
import UIKit

public struct PDFExportSceneFactory: ResolvableSceneFactory {
    // MARK: - Properties

    let token: ExtendedCBORWebToken

    // MARK: - Lifecycle

    public init(token: ExtendedCBORWebToken) {
        self.token = token
    }

    public func make(resolvable: Resolver<Void>) -> UIViewController {
        guard let exporter = SVGPDFExporter() else {
            fatalError("initialization of SVGPDFExporter failed")
        }
        let viewModel = PDFExportViewModel(
            token: token,
            resolvable: resolvable,
            exporter: exporter
        )
        let viewController = PDFExportViewController(viewModel: viewModel)
        return viewController
    }
}
