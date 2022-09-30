//
//  MaskOptionalResultViewControllerSnapshotTests.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassCheckApp
import CovPassCommon
import CovPassUI
import PromiseKit
import XCTest

final class MaskOptionalResultViewControllerSnapshotTests: BaseSnapShotTests {
    private var sut: MaskOptionalResultViewController!

    override func setUpWithError() throws {
        try super.setUpWithError()
        let (_, resolver) = Promise<Void>.pending()
        let countdownTimerModel = CountdownTimerModel(
            dismissAfterSeconds: 100,
            countdownDuration: 0
        )
        let token = CBORWebToken.mockVaccinationCertificate.extended()
        let viewModel = MaskOptionalResultViewModel(
            token: token,
            countdownTimerModel: countdownTimerModel,
            resolver: resolver,
            router: MaskOptionalResultRouterMock(),
            persistence: MockPersistence(),
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
