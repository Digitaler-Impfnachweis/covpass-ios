//
//  GProofDifferentPersonSnapShotTests.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassCheckApp
import XCTest
import CovPassUI
import CovPassCommon
import PromiseKit

class GProofDifferentPersonViewControllerSnapshotTests: BaseSnapShotTests {
    private var sut: GProofDifferentPersonViewController!

    override func setUpWithError() throws {
        try super.setUpWithError()
        configureSut()
    }

    private func configureSut(dob: Date? = nil, hideCountdown: Bool = true) {
        let gProofToken = CBORWebToken.mockVaccinationCertificate
        var testToken = CBORWebToken.mockTestCertificate
        let (_, resolver) = Promise<GProofResult>.pending()
        let countdownTimerModel = CountdownTimerModelMock()
        countdownTimerModel.mockedHideCountdown = hideCountdown
        if let dob = dob {
            testToken.hcert.dgc.dob = dob
        }
        let vm = GProofDifferentPersonViewModel(
            firstResultCert: gProofToken,
            secondResultCert: testToken,
            resolver: resolver,
            countdownTimerModel: countdownTimerModel
        )
        sut = GProofDifferentPersonViewController(viewModel: vm)
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
        sut = nil
    }
    
    func testSameDob() {
        verifyView(vc: sut)
    }
    
    func testDifferentDob() {
        // Given
        configureSut(dob: DateUtils.parseDate("1999-04-26T15:05:00")!)

        // When & Then
        verifyView(vc: sut)
    }

    func testCountdown() {
        // Given
        configureSut(hideCountdown: false)

        // When & Then
        verifyView(vc: sut)
    }
}
