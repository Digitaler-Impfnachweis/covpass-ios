//
//  CertificateItemDetailViewModelTests.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassApp
@testable import CovPassCommon
@testable import CovPassUI
import XCTest
import PromiseKit

class CertificateItemDetailViewModelTests: XCTestCase {
    
    private var sut: CertificateItemDetailViewModel!
    
    private func configureSut(token: ExtendedCBORWebToken) {
        let (_, resolver) = Promise<CertificateDetailSceneResult>.pending()
        sut = CertificateItemDetailViewModel(router: CertificateItemDetailRouterMock(),
                                             repository: VaccinationRepositoryMock(),
                                             certificate: token,
                                             resolvable: resolver,
                                             vaasResultToken: nil)
    }
    
    func testGerman() {
        // GIVEN
        let token = CBORWebToken.mockVaccinationCertificate
        token.hcert.dgc.v!.first!.co = "DE"
        // WHEN
        configureSut(token: token.extended())
        // THEN
        let countryVaccinationValue = sut.items[9].value
        XCTAssertEqual(countryVaccinationValue, "Germany")
    }
    
    func testTurkish() {
        // GIVEN
        let token = CBORWebToken.mockVaccinationCertificate
        token.hcert.dgc.v!.first!.co = "TR"
        // WHEN
        configureSut(token: token.extended())
        // THEN
        let countryVaccinationValue = sut.items[9].value
        XCTAssertEqual(countryVaccinationValue, "Turkey")
    }
    
    func testGreatBritain() {
        // GIVEN
        let token = CBORWebToken.mockVaccinationCertificate
        token.hcert.dgc.v!.first!.co = "GB"
        // WHEN
        configureSut(token: token.extended())
        // THEN
        let countryVaccinationValue = sut.items[9].value
        XCTAssertEqual(countryVaccinationValue, "Great Britain")
    }
    
    func testChina() {
        // GIVEN
        let token = CBORWebToken.mockVaccinationCertificate
        token.hcert.dgc.v!.first!.co = "CN"
        // WHEN
        configureSut(token: token.extended())
        // THEN
        let countryVaccinationValue = sut.items[9].value
        XCTAssertEqual(countryVaccinationValue, "CN")
    }
}
