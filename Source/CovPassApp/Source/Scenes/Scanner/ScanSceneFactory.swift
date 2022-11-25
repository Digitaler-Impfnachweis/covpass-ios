//
//  ScanSceneFactory.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import CovPassUI
import PromiseKit
import UIKit

public struct ScanSceneFactory: ResolvableSceneFactory {
    // MARK: - Lifecycle

    private let cameraAccessProvider: CameraAccessProviderProtocol
    private let router: ScanRouterProtocol
    private let isDocumentPickerEnabled: Bool

    public init(cameraAccessProvider: CameraAccessProviderProtocol,
                router: ScanRouterProtocol,
                isDocumentPickerEnabled: Bool) {
        self.cameraAccessProvider = cameraAccessProvider
        self.router = router
        self.isDocumentPickerEnabled = isDocumentPickerEnabled
    }

    // MARK: - Methods

    public func make(resolvable: Resolver<QRCodeImportResult>) -> UIViewController {
        guard let pdfCBORExtractor = PDFCBORExtractor() else {
            fatalError()
        }
        let certificateRepository = VaccinationRepository.create()
        let viewModel = ScanViewModel(
            cameraAccessProvider: cameraAccessProvider,
            resolvable: resolvable,
            router: router,
            isDocumentPickerEnabled: isDocumentPickerEnabled,
            certificateExtractor: pdfCBORExtractor,
            certificateRepository: certificateRepository
        )
        let viewController = ScanViewController(viewModel: viewModel)

        return viewController
    }
}
