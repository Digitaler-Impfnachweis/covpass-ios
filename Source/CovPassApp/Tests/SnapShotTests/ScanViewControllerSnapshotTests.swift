//
//  ScanViewControllerSnapshotTests.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassApp
@testable import CovPassCommon
@testable import CovPassUI
import PromiseKit
import UIKit

class ScanViewSnapShotTests: BaseSnapShotTests {
    func testDefault() {
        let viewModel = viewModel()
        let viewController = ScanViewController(viewModel: viewModel)
        verifyView(view: viewController.view, height: 500)
    }

    private func viewModel(isDocumentPickerEnabled: Bool = false) -> ScanViewModel {
        let (_, resolver) = Promise<QRCodeImportResult>.pending()
        let router = ScanRouterMock()
        let viewModel = ScanViewModel(
            cameraAccessProvider: CameraAccessProviderMock(),
            resolvable: resolver,
            router: router,
            isDocumentPickerEnabled: isDocumentPickerEnabled,
            certificateExtractor: CertificateExtractorMock(),
            certificateRepository: VaccinationRepositoryMock()
        )
        return viewModel
    }

    func testIsDocumentPickerEnabled() {
        let viewModel = viewModel(isDocumentPickerEnabled: true)
        let viewController = ScanViewController(viewModel: viewModel)
        verifyView(view: viewController.view, height: 500)
    }
}
