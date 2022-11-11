//
//  CertificateInvalidResultViewControllerSnapshotTests.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassCheckApp
import CovPassCommon
import CovPassUI
import PromiseKit
import XCTest

final class CertificateInvalidResultViewControllerSnapshotTests: BaseSnapShotTests {
    private var sut: CertificateInvalidResultViewController!

    override func setUpWithError() throws {
        try super.setUpWithError()
        let (_, resolver) = Promise<ValidatorDetailSceneResult>.pending()
        let countdownTimerModel = CountdownTimerModel(
            dismissAfterSeconds: 100,
            countdownDuration: 0
        )
        let token = CBORWebToken.mockVaccinationCertificate.extended()
        var persistence = MockPersistence()
        persistence.revocationExpertMode = true
        let viewModel = CertificateInvalidResultViewModel(
            token: token,
            countdownTimerModel: countdownTimerModel,
            resolver: resolver,
            router: CertificateInvalidResultRouterMock(),
            persistence: persistence,
            revocationKeyFilename: ""
        )
        sut = .init(viewModel: viewModel)
    }

    override func tearDownWithError() throws {
        sut = nil
        try super.tearDownWithError()
    }

    func testDefault() throws {
        verifyView(view: sut.view, height: 1000)
    }
}
