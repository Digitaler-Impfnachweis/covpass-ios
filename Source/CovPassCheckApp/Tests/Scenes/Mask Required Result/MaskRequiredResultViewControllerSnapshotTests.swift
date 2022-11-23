//
//  MaskRequiredResultViewControllerSnapshotTests.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassCheckApp
import CovPassUI
import PromiseKit
import XCTest
import CovPassCommon

final class MaskRequiredResultViewControllerSnapshotTests: BaseSnapShotTests {
    private var sut: MaskRequiredResultViewController!

    override func setUpWithError() throws {
        try super.setUpWithError()
        configureSut()
    }

    func configureSut(secondCertificateHintHidden: Bool = true) {
        let (_, resolver) = Promise<ValidatorDetailSceneResult>.pending()
        let countdownTimerModel = CountdownTimerModel(
            dismissAfterSeconds: 100,
            countdownDuration: 0
        )
        var persistence = MockPersistence()
        persistence.revocationExpertMode = true
        persistence.stateSelection = "NW"
        let certificateHolderStatus = CertificateHolderStatusModelMock()
        certificateHolderStatus.latestMaskRuleDate = DateUtils.parseDate("2021-04-26T15:05:00")
        let viewModel = MaskRequiredResultViewModel(
            token: CBORWebToken.mockVaccinationCertificate.extended(),
            countdownTimerModel: countdownTimerModel,
            resolver: resolver,
            router: MaskRequiredResultRouterMock(),
            reasonType: .functional,
            secondCertificateHintHidden: secondCertificateHintHidden,
            persistence: persistence,
            certificateHolderStatus: certificateHolderStatus,
            revocationKeyFilename: ""
        )
        sut = .init(viewModel: viewModel)
    }

    override func tearDownWithError() throws {
        sut = nil
        try super.tearDownWithError()
    }

    func testDefault() throws {
        verifyView(view: sut.view, height: 1100)
    }

    func test_hint_not_hidden() {
        // Given
        configureSut(secondCertificateHintHidden: false)

        // When & Then
        verifyView(view: sut.view, height: 1350)
    }
}
