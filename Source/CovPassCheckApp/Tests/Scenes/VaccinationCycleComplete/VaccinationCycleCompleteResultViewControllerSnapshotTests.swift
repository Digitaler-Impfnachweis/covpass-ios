//
//  VaccinationCycleCompleteResultViewControllerSnapshotTests.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassCheckApp
import CovPassCommon
import CovPassUI
import PromiseKit
import XCTest

final class VaccinationCycleCompleteResultViewControllerSnapshotTests: BaseSnapShotTests {
    private var sut: VaccinationCycleCompleteResultViewController!

    private func configureSut(checkSituation: CheckSituationType) {
        let (_, resolver) = Promise<ValidatorDetailSceneResult>.pending()
        let countdownTimerModel = CountdownTimerModel(
            dismissAfterSeconds: 100,
            countdownDuration: 0
        )
        let token = CBORWebToken.mockVaccinationCertificate.extended()
        var persistence = MockPersistence()
        persistence.revocationExpertMode = true
        persistence.checkSituation = checkSituation.rawValue
        let viewModel = VaccinationCycleCompleteResultViewModel(
            token: token,
            countdownTimerModel: countdownTimerModel,
            resolver: resolver,
            router: VaccinationCycleCompleteResultRouterMock(),
            persistence: persistence,
            revocationKeyFilename: ""
        )
        sut = .init(viewModel: viewModel)
    }

    override func setUpWithError() throws {
        try super.setUpWithError()
        configureSut(checkSituation: .withinGermany)
    }

    override func tearDownWithError() throws {
        sut = nil
        try super.tearDownWithError()
    }

    func testDefault() throws {
        configureSut(checkSituation: .withinGermany)
        verifyView(view: sut.view, height: 1000)
    }

    func testDefault_enteringGermany() throws {
        configureSut(checkSituation: .enteringGermany)
        verifyView(view: sut.view, height: 1000)
    }
}
