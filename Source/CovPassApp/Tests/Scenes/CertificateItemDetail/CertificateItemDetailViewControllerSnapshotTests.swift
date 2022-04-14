//
//  CertificateItemDetailViewControllerSnapshotTests.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassApp
import CovPassCommon
import XCTest

class CertificateItemDetailViewControllerSnapshotTests: BaseSnapShotTests {
    func testRevokedCertificate() throws {
        // Given
        var token = try ExtendedCBORWebToken.token1Of1()
        token.revoked = true
        let viewModel = CertificateItemDetailViewModel(
            router: CertificateItemDetailRouterMock(),
            repository: VaccinationRepositoryMock(),
            certificate: token,
            resolvable: nil,
            vaasResultToken: nil
        )
        let viewController = CertificateItemDetailViewController(
            viewModel: viewModel
        )

        // When & Then
        verifyView(view: viewController.view, height: 1800)
    }
}
