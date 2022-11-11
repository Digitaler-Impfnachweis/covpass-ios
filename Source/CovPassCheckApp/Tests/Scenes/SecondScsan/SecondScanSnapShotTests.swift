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
        configureSut(isThirdScan: false)
    }

    override func tearDownWithError() throws {
        sut = nil
        try super.tearDownWithError()
    }
    
    func configureSut(isThirdScan: Bool) {
        let (_, resolver) = Promise<ValidatorDetailSceneResult>.pending()
        let countdownTimerModel = CountdownTimerModel(
            dismissAfterSeconds: 100,
            countdownDuration: 0
        )
        let token = CBORWebToken.mockVaccinationCertificate.extended()
        let viewModel = SecondScanViewModel(resolver: resolver,
                                            isThirdScan: isThirdScan,
                                            token: token,
                                            countdownTimerModel: countdownTimerModel)
        sut = .init(viewModel: viewModel)
    }
    
    func testDefault() throws {
        verifyView(view: sut.view, height: 1000)
    }
    
    func testDefaultThirdScan() throws {
        configureSut(isThirdScan: true)
        verifyView(view: sut.view, height: 1000)
    }
}
