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
    private var sut: CertificateItemDetailViewController!

    override func setUpWithError() throws {
        try super.setUpWithError()
        try configureSut(token: .token1Of1())
    }

    private func configureSut(token: ExtendedCBORWebToken) {
        let viewModel = CertificateItemDetailViewModel(
            router: CertificateItemDetailRouterMock(),
            repository: VaccinationRepositoryMock(),
            certificate: token,
            resolvable: nil,
            vaasResultToken: nil
        )
        sut = CertificateItemDetailViewController(viewModel: viewModel)
    }

    override func tearDownWithError() throws {
        sut = nil
        try super.tearDownWithError()
    }

    func testRevokedCertificate() throws {
        // Given
        var token = try ExtendedCBORWebToken.token1Of1()
        token.revoked = true
        configureSut(token: token)
        RunLoop.main.run(for: 0.1)

        // When & Then
        verifyView(view: sut.view, height: 1800)
    }
    
    func testInvalidCertificate() throws {
        // Given
        var token = try ExtendedCBORWebToken.token1Of1()
        token.invalid = true
        configureSut(token: token)

        RunLoop.main.run(for: 0.1)
        // When & Then
        verifyView(view: sut.view, height: 1800)
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

    func testExpiredCertificate() throws {
        // Given
        var token = try ExtendedCBORWebToken.token1Of1()
        token.vaccinationCertificate.exp = .init(timeIntervalSinceReferenceDate: 0)
        configureSut(token: token)

        // When & Then
        verifyView(view: sut.view, height: 1800)
    }

    func testExpiredCertificate_non_german_issuer() throws {
        // Given
        var token = try ExtendedCBORWebToken.token1Of1()
        token.vaccinationCertificate.exp = .init(timeIntervalSinceReferenceDate: 0)
        token.vaccinationCertificate.iss = "FR"
        configureSut(token: token)

        // When & Then
        verifyView(view: sut.view, height: 1800)
    }

    func testRecovery() throws {
        // Given
        var token = CBORWebToken.mockRecoveryCertificate.extended()
        token.vaccinationCertificate.exp = .init(timeIntervalSinceReferenceDate: 0)
        configureSut(token: token)

        // When & Then
        verifyView(view: sut.view, height: 1800)
    }

    func testTest() throws {
        // Given
        var token = CBORWebToken.mockTestCertificate.extended()
        token.vaccinationCertificate.exp = .init(timeIntervalSinceReferenceDate: 0)
        let test = try XCTUnwrap(token.vaccinationCertificate.hcert.dgc.t?.first)
        test.sc = .init(timeIntervalSinceReferenceDate: 60)
        token.vaccinationCertificate.hcert.dgc.t = [test]
        configureSut(token: token)

        // When & Then
        verifyView(view: sut.view, height: 1800)
    }
}

private class CertificateItemDetailViewModelMock: CertificateItemDetailViewModel {
    override var expiresSoonDate: Date? {
        Date(timeIntervalSinceReferenceDate: 0)
    }
}
