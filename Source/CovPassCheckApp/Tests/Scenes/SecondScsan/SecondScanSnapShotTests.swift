//
//  SecondScanSnapShotTests.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassCheckApp
import CovPassCommon
import CovPassUI
import PromiseKit
import XCTest

class SecondScanSnapShotTests: BaseSnapShotTests {
    private var sut: SecondScanViewController!

    override func setUpWithError() throws {
        try super.setUpWithError()
        configureSut(secondToken: nil)
    }

    override func tearDownWithError() throws {
        sut = nil
        try super.tearDownWithError()
    }

    func configureSut(secondToken: ExtendedCBORWebToken?) {
        let (_, resolver) = Promise<ValidatorDetailSceneResult>.pending()
        let countdownTimerModel = CountdownTimerModel(
            dismissAfterSeconds: 100,
            countdownDuration: 0
        )
        let token = CBORWebToken.mockVaccinationCertificate.extended()
        var tokens = [token]
        if let token = secondToken {
            tokens.append(token)
        }
        let viewModel = SecondScanViewModel(resolver: resolver,
                                            tokens: tokens,
                                            countdownTimerModel: countdownTimerModel)
        sut = .init(viewModel: viewModel)
    }

    func testDefault() throws {
        verifyView(view: sut.view, height: 1000)
    }

    func testDefaultThirdScan() throws {
        configureSut(secondToken: CBORWebToken.mockRecoveryCertificate.extended())
        verifyView(view: sut.view, height: 1000)
    }
}
