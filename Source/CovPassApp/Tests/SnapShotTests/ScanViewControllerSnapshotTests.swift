//
//  ScanViewControllerSnapshotTests.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassApp
@testable import CovPassUI
@testable import CovPassCommon
import PromiseKit
import UIKit

class ScanViewSnapShotTests: BaseSnapShotTests {
    func testDefault() {
        let (_, resolver) = Promise<ScanResult>.pending()
        let router = ScanRouterMock()
        let viewModel = ScanViewModel(
            cameraAccessProvider: CameraAccessProviderMock(),
            resolvable: resolver,
            router: router,
            isDocumentPickerEnabled: false,
            certificateExtractor: CertificateExtractorMock(),
            certificateRepository: VaccinationRepositoryMock()
        )
        let viewController = ScanViewController(viewModel: viewModel)
        verifyView(view: viewController.view, height: 500)
    }
    
    func testIsDocumentPickerEnabled() {
        let (_, resolver) = Promise<ScanResult>.pending()
        let router = ScanRouterMock()
        let viewModel = ScanViewModel(
            cameraAccessProvider: CameraAccessProviderMock(),
            resolvable: resolver,
            router: router,
            isDocumentPickerEnabled: true,
            certificateExtractor: CertificateExtractorMock(),
            certificateRepository: VaccinationRepositoryMock()
        )
        let viewController = ScanViewController(viewModel: viewModel)
        verifyView(view: viewController.view, height: 500)
    }
}

