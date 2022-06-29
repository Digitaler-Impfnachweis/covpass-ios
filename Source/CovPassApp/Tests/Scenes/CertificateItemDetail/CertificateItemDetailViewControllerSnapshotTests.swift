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
        RunLoop.main.run(for: 0.1)
        // When & Then
        verifyView(view: viewController.view, height: 1800)
    }
    
    func testInvalidCertificate() throws {
        // Given
        var token = try ExtendedCBORWebToken.token1Of1()
        token.invalid = true
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
        RunLoop.main.run(for: 0.1)
        // When & Then
        verifyView(view: viewController.view, height: 1800)
    }

    func testExpiringCertificate() throws {
        // Given
        var token = try ExtendedCBORWebToken.token1Of1()
        token.vaccinationCertificate.exp = Date(timeIntervalSinceNow: 60)
        let viewModel = CertificateItemDetailViewModelMock(
            router: CertificateItemDetailRouterMock(),
            repository: VaccinationRepositoryMock(),
            certificate: token,
            resolvable: nil,
            vaasResultToken: nil
        )
        let sut = CertificateItemDetailViewController(
            viewModel: viewModel
        )

        // When & Then
        verifyView(view: sut.view)
    }
}

private class CertificateItemDetailViewModelMock: CertificateItemDetailViewModel {
    override var expiresSoonDate: Date? {
        Date(timeIntervalSinceReferenceDate: 0)
    }
}
