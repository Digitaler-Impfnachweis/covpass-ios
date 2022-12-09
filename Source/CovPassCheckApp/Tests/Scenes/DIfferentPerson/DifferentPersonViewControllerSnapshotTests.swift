//
//  DifferentPersonSnapShotTests.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassCheckApp
import CovPassCommon
import CovPassUI
import PromiseKit
import XCTest

class DifferentPersonViewControllerSnapshotTests: BaseSnapShotTests {
    private var sut: DifferentPersonViewController!

    override func setUpWithError() throws {
        try super.setUpWithError()
        try configureSut()
    }

    private func configureSut(dob: Date? = nil,
                              hideCountdown: Bool = true,
                              thirdToken: ExtendedCBORWebToken? = nil) throws {
        var token1 = CBORWebToken.mockVaccinationCertificate.extended()
        token1.vaccinationCertificate.hcert.dgc.nam.gnt = "JOHANNA"
        token1.vaccinationCertificate.hcert.dgc.nam.gn = "Johanna"
        token1.vaccinationCertificate.hcert.dgc.nam.fnt = "MUSTERMANN"
        token1.vaccinationCertificate.hcert.dgc.nam.fn = "Mustermann"
        token1.vaccinationCertificate.hcert.dgc.dob = try XCTUnwrap(DateUtils.parseDate("1955-05-05T15:05:00"))
        var token2 = CBORWebToken.mockTestCertificate.extended()
        token2.vaccinationCertificate.hcert.dgc.nam.gnt = "JOHANNA"
        token2.vaccinationCertificate.hcert.dgc.nam.gn = "Johanna"
        token2.vaccinationCertificate.hcert.dgc.nam.fnt = "MUSTERMANN"
        token2.vaccinationCertificate.hcert.dgc.nam.fn = "Mustermann"
        token2.vaccinationCertificate.hcert.dgc.dob = try XCTUnwrap(DateUtils.parseDate("1955-05-05T15:05:00"))
        let (_, resolver) = Promise<ValidatorDetailSceneResult>.pending()
        let countdownTimerModel = CountdownTimerModelMock()
        countdownTimerModel.mockedHideCountdown = hideCountdown
        if let dob = dob {
            token2.vaccinationCertificate.hcert.dgc.dob = dob
        }
        let vm = DifferentPersonViewModel(
            firstToken: token1,
            secondToken: token2,
            thirdToken: thirdToken,
            resolver: resolver,
            countdownTimerModel: countdownTimerModel
        )
        sut = DifferentPersonViewController(viewModel: vm)
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
        sut = nil
    }

    func testSameDob() {
        verifyView(view: sut.view, height: 1022)
    }

    func test_sameDob_threeCertificates_() throws {
        // Given
        var token1 = CBORWebToken.mockVaccinationCertificate.extended()
        token1.vaccinationCertificate.hcert.dgc.nam.gnt = "MAXIMILIAN"
        token1.vaccinationCertificate.hcert.dgc.nam.gn = "Maximilian"
        token1.vaccinationCertificate.hcert.dgc.nam.fnt = "MUSTERMANN"
        token1.vaccinationCertificate.hcert.dgc.nam.fn = "Mustermann"
        token1.vaccinationCertificate.hcert.dgc.dob = try XCTUnwrap(DateUtils.parseDate("1955-05-05T15:05:00"))

        try configureSut(thirdToken: token1)

        verifyView(view: sut.view, height: 1022)
    }

    func test_differentDob_() throws {
        // Given
        try configureSut(dob: DateUtils.parseDate("1999-04-26T15:05:00")!)

        // When & Then
        verifyView(view: sut.view, height: 1022)
    }

    func test_countdown_() throws {
        // Given
        try configureSut(hideCountdown: false)

        // When & Then
        verifyView(view: sut.view, height: 720)
    }
}
