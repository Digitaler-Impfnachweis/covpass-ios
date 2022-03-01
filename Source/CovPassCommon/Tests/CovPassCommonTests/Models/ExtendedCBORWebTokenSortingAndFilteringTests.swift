//
//  CertificateSorterTests.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import PromiseKit
import XCTest

@testable import CovPassCommon

extension CBORWebToken {
    func mockName(_ name: Name) -> Self {
        var token = self
        token.hcert.dgc.nam = name
        return token
    }
    
    func mockVaccinationUVCI(_ uvci: String) -> Self {
        hcert.dgc.v?.first?.ci = uvci
        return self
    }
    
    func mockTestUVCI(_ uvci: String) -> Self {
        hcert.dgc.t?.first?.ci = uvci
        return self
    }
    
    func mockRecoveryUVCI(_ uvci: String) -> Self {
        hcert.dgc.r?.first?.ci = uvci
        return self
    }

    func mockVaccinationSetDate(_ date: Date) -> Self {
        hcert.dgc.v?.first?.dt = date
        return self
    }
    
    func doseNumber(_ dn: Int) -> Self {
        hcert.dgc.v?.first?.dn = dn
        return self
    }
    
    func seriesOfDoses(_ sd: Int) -> Self {
        hcert.dgc.v?.first?.sd = sd
        return self
    }
    
    func medicalProduct(_ mp: MedicalProduct) -> Self {
        hcert.dgc.v?.first?.mp = mp.rawValue
        return self
    }

    func extended(vaccinationQRCodeData: String = "") -> ExtendedCBORWebToken {
        ExtendedCBORWebToken(vaccinationCertificate: self,
                             vaccinationQRCodeData: vaccinationQRCodeData)
    }
}

class CertificateSorterTests: XCTestCase {
    
    func testSorting() throws {
        let certificates = [
            CBORWebToken
                .mockVaccinationCertificate
                .mockVaccinationUVCI("1")
                .mockVaccinationSetDate(Date())
                .extended(),
            CBORWebToken
                .mockVaccinationCertificate
                .mockVaccinationUVCI("2")
                .mockVaccinationSetDate(Calendar.current.date(byAdding: .day, value: -20, to: Date())!)
                .extended()
        ]
        let sortedCertifiates = certificates.sortLatest()

        XCTAssertEqual(sortedCertifiates.count, 2)
        XCTAssertEqual(sortedCertifiates[0].vaccinationCertificate.hcert.dgc.uvci, "2")
        XCTAssertEqual(sortedCertifiates[1].vaccinationCertificate.hcert.dgc.uvci, "1")
    }
    
    func testLatestIatCertOnSameVaccinationDate() throws {
        // GIVEN
        let vacinationDate = DateUtils.parseDate("2021-04-26T15:05:00")!
        var firstCert: ExtendedCBORWebToken = CBORWebToken
            .mockVaccinationCertificate
            .mockVaccinationUVCI("1")
            .mockVaccinationSetDate(vacinationDate)
            .extended(vaccinationQRCodeData:"1")
        firstCert.vaccinationCertificate.iat = DateUtils.parseDate("2021-04-26T15:05:00")

        var secondCert: ExtendedCBORWebToken = CBORWebToken
            .mockVaccinationCertificate
            .mockVaccinationUVCI("2")
            .mockVaccinationSetDate(vacinationDate)
            .extended(vaccinationQRCodeData:"2")
        secondCert.vaccinationCertificate.iat = DateUtils.parseDate("2021-04-27T15:05:00")

        var thirdCert: ExtendedCBORWebToken = CBORWebToken
            .mockVaccinationCertificate
            .mockVaccinationUVCI("3")
            .mockVaccinationSetDate(vacinationDate)
            .extended(vaccinationQRCodeData:"3")
        thirdCert.vaccinationCertificate.iat = DateUtils.parseDate("2021-04-28T15:05:00")

        let certificates = [
            secondCert,
            firstCert,
            thirdCert
        ]
        
        // WHEN
        let sortedCertifiates = certificates.sortLatest()

        // THEN
        XCTAssertEqual(sortedCertifiates.count, 3)
        XCTAssertEqual(sortedCertifiates[0].vaccinationCertificate.hcert.dgc.uvci, "3")
    }
    
    func testLatestIatCertOnSameVaccinationDateButOneOfThemHasNoIat() throws {
        // GIVEN
        let vacinationDate = DateUtils.parseDate("2021-04-26T15:05:00")!
        var firstCert: ExtendedCBORWebToken = CBORWebToken
            .mockVaccinationCertificate
            .mockVaccinationUVCI("1")
            .mockVaccinationSetDate(vacinationDate)
            .extended(vaccinationQRCodeData:"1")
        firstCert.vaccinationCertificate.iat = DateUtils.parseDate("2021-04-26T15:05:00")

        var secondCert: ExtendedCBORWebToken = CBORWebToken
            .mockVaccinationCertificate
            .mockVaccinationUVCI("2")
            .mockVaccinationSetDate(vacinationDate)
            .extended(vaccinationQRCodeData:"2")
        secondCert.vaccinationCertificate.iat = DateUtils.parseDate("2021-04-27T15:05:00")

        var thirdCert: ExtendedCBORWebToken = CBORWebToken
            .mockVaccinationCertificate
            .mockVaccinationUVCI("3")
            .mockVaccinationSetDate(vacinationDate)
            .extended(vaccinationQRCodeData:"3")
        thirdCert.vaccinationCertificate.iat = DateUtils.parseDate("2021-04-28T15:05:00")

        var fourthCert: ExtendedCBORWebToken = CBORWebToken
            .mockVaccinationCertificate
            .mockVaccinationUVCI("4")
            .mockVaccinationSetDate(vacinationDate)
            .extended(vaccinationQRCodeData:"4")
        fourthCert.vaccinationCertificate.iat = nil

        let certificates = [
            secondCert,
            firstCert,
            thirdCert,
            fourthCert
        ]
        
        // WHEN
        let sortedCertifiates = certificates.sortLatest()

        // THEN
        XCTAssertEqual(sortedCertifiates.count, 4)
        XCTAssertEqual(sortedCertifiates[0].vaccinationCertificate.hcert.dgc.uvci, "3")
    }
    
    func testLatestIatCertOnSameVaccinationDateButTwoOfThemHasNoIatButOneOfTheseTwoIsLatestVac() throws {
        // GIVEN
        let vacinationDate = DateUtils.parseDate("2021-04-26T15:05:00")!
        let vacinationDateLate = DateUtils.parseDate("2021-04-27T15:05:00")!
        var firstCert: ExtendedCBORWebToken = CBORWebToken
            .mockVaccinationCertificate
            .mockVaccinationUVCI("1")
            .mockVaccinationSetDate(vacinationDate)
            .extended(vaccinationQRCodeData:"1")
        firstCert.vaccinationCertificate.iat = DateUtils.parseDate("2021-04-26T15:05:00")

        var secondCert: ExtendedCBORWebToken = CBORWebToken
            .mockVaccinationCertificate
            .mockVaccinationUVCI("2")
            .mockVaccinationSetDate(vacinationDate)
            .extended(vaccinationQRCodeData:"2")
        secondCert.vaccinationCertificate.iat = DateUtils.parseDate("2021-04-27T15:05:00")

        var thirdCert: ExtendedCBORWebToken = CBORWebToken
            .mockVaccinationCertificate
            .mockVaccinationUVCI("3")
            .mockVaccinationSetDate(vacinationDate)
            .extended(vaccinationQRCodeData:"3")
        thirdCert.vaccinationCertificate.iat = DateUtils.parseDate("2021-04-28T15:05:00")

        var fourthCert: ExtendedCBORWebToken = CBORWebToken
            .mockVaccinationCertificate
            .mockVaccinationUVCI("4")
            .mockVaccinationSetDate(vacinationDate)
            .extended(vaccinationQRCodeData:"4")
        fourthCert.vaccinationCertificate.iat = nil
        
        var fifthCert: ExtendedCBORWebToken = CBORWebToken
            .mockVaccinationCertificate
            .mockVaccinationUVCI("5")
            .mockVaccinationSetDate(vacinationDateLate)
            .extended(vaccinationQRCodeData:"5")
        fifthCert.vaccinationCertificate.iat = nil

        let certificates = [
            secondCert,
            firstCert,
            fifthCert,
            thirdCert,
            fourthCert
        ]
        
        // WHEN
        let sortedCertifiates = certificates.sortLatest()

        // THEN
        XCTAssertEqual(sortedCertifiates.count, 5)
        XCTAssertEqual(sortedCertifiates[0].vaccinationCertificate.hcert.dgc.uvci, "5")
    }
    
    func testSortingVacBasedOnIatAndWithCertWhereIatIsNilAndOneCertificateIsNotPosNotPcr() throws {
        // GIVEN
        let vacinationDate = DateUtils.parseDate("2021-04-26T15:05:00")!
        let vacinationDateLate = DateUtils.parseDate("2021-04-27T15:05:00")!
        let testDateLater = Date().addingTimeInterval(-86400)
        var firstCert: ExtendedCBORWebToken = CBORWebToken
            .mockVaccinationCertificate
            .mockVaccinationUVCI("1")
            .mockVaccinationSetDate(vacinationDate)
            .extended(vaccinationQRCodeData:"1")
        firstCert.vaccinationCertificate.iat = DateUtils.parseDate("2021-04-26T15:05:00")

        var secondCert: ExtendedCBORWebToken = CBORWebToken
            .mockVaccinationCertificate
            .mockVaccinationUVCI("2")
            .mockVaccinationSetDate(vacinationDate)
            .extended(vaccinationQRCodeData:"2")
        secondCert.vaccinationCertificate.iat = DateUtils.parseDate("2021-04-27T15:05:00")

        var thirdCert: ExtendedCBORWebToken = CBORWebToken
            .mockVaccinationCertificate
            .mockVaccinationUVCI("3")
            .mockVaccinationSetDate(vacinationDate)
            .extended(vaccinationQRCodeData:"3")
        thirdCert.vaccinationCertificate.iat = DateUtils.parseDate("2021-04-28T15:05:00")

        var fourthCert: ExtendedCBORWebToken = CBORWebToken
            .mockVaccinationCertificate
            .mockVaccinationUVCI("4")
            .mockVaccinationSetDate(vacinationDate)
            .extended(vaccinationQRCodeData:"4")
        fourthCert.vaccinationCertificate.iat = nil
        
        var fifthCert: ExtendedCBORWebToken = CBORWebToken
            .mockVaccinationCertificate
            .mockVaccinationUVCI("5")
            .mockVaccinationSetDate(vacinationDateLate)
            .extended(vaccinationQRCodeData:"5")
        fifthCert.vaccinationCertificate.iat = nil

        
        let sixtCert: ExtendedCBORWebToken = CBORWebToken
            .mockTestCertificate
            .mockTestUVCI("6")
            .mockVaccinationSetDate(testDateLater)
            .extended(vaccinationQRCodeData:"6")
        sixtCert.vaccinationCertificate.hcert.dgc.t!.first!.tt = "NOT PCR"
        sixtCert.vaccinationCertificate.hcert.dgc.t!.first!.tr = "NOT POSTIIVE"
        sixtCert.vaccinationCertificate.hcert.dgc.t!.first!.sc = testDateLater

        let certificates = [
            secondCert,
            firstCert,
            fifthCert,
            sixtCert,
            thirdCert,
            fourthCert
        ]
        
        // WHEN
        let sortedCertifiates = certificates.sortLatest()

        // THEN
        XCTAssertEqual(sortedCertifiates.count, 6)
        XCTAssertEqual(sortedCertifiates[0].vaccinationCertificate.hcert.dgc.uvci, "6")
    }
    
    
    func testSortingVacBasedOnIatAndAllCerIatIsNil() throws {
        // GIVEN
        let vacinationDate = DateUtils.parseDate("2021-04-26T15:05:00")!
        let vacinationDateLate = DateUtils.parseDate("2021-04-27T15:05:00")!
        var firstCert: ExtendedCBORWebToken = CBORWebToken
            .mockVaccinationCertificate
            .mockVaccinationUVCI("1")
            .mockVaccinationSetDate(vacinationDate)
            .extended(vaccinationQRCodeData:"1")
        firstCert.vaccinationCertificate.iat = nil

        var secondCert: ExtendedCBORWebToken = CBORWebToken
            .mockVaccinationCertificate
            .mockVaccinationUVCI("2")
            .mockVaccinationSetDate(vacinationDate)
            .extended(vaccinationQRCodeData:"2")
        secondCert.vaccinationCertificate.iat = nil

        var thirdCert: ExtendedCBORWebToken = CBORWebToken
            .mockVaccinationCertificate
            .mockVaccinationUVCI("3")
            .mockVaccinationSetDate(vacinationDate)
            .extended(vaccinationQRCodeData:"3")
        thirdCert.vaccinationCertificate.iat = nil

        var fourthCert: ExtendedCBORWebToken = CBORWebToken
            .mockVaccinationCertificate
            .mockVaccinationUVCI("4")
            .mockVaccinationSetDate(vacinationDate)
            .extended(vaccinationQRCodeData:"4")
        fourthCert.vaccinationCertificate.iat = nil
        
        var fifthCert: ExtendedCBORWebToken = CBORWebToken
            .mockVaccinationCertificate
            .mockVaccinationUVCI("5")
            .mockVaccinationSetDate(vacinationDateLate)
            .extended(vaccinationQRCodeData:"5")
        fifthCert.vaccinationCertificate.iat = nil

        let certificates = [
            secondCert,
            firstCert,
            fifthCert,
            thirdCert,
            fourthCert
        ]
        
        // WHEN
        let sortedCertifiates = certificates.sortLatest()

        // THEN
        XCTAssertEqual(sortedCertifiates.count, 5)
        XCTAssertEqual(sortedCertifiates[0].vaccinationCertificate.hcert.dgc.uvci, "5")
    }
    
    
    func testSortingVacBasedOnIatAndAllCerIatIsNilOneCertVacDateDiffer() throws {
        // GIVEN
        let vacinationDate = DateUtils.parseDate("2021-04-26T15:05:00")!
        let vacinationDateLate = DateUtils.parseDate("2021-04-27T15:05:00")!
        var firstCert: ExtendedCBORWebToken = CBORWebToken
            .mockVaccinationCertificate
            .mockVaccinationUVCI("1")
            .mockVaccinationSetDate(vacinationDateLate)
            .extended(vaccinationQRCodeData:"1")
        firstCert.vaccinationCertificate.iat = nil

        var secondCert: ExtendedCBORWebToken = CBORWebToken
            .mockVaccinationCertificate
            .mockVaccinationUVCI("2")
            .mockVaccinationSetDate(vacinationDateLate)
            .extended(vaccinationQRCodeData:"2")
        secondCert.vaccinationCertificate.iat = nil

        var thirdCert: ExtendedCBORWebToken = CBORWebToken
            .mockVaccinationCertificate
            .mockVaccinationUVCI("3")
            .mockVaccinationSetDate(vacinationDate)
            .extended(vaccinationQRCodeData:"3")
        thirdCert.vaccinationCertificate.iat = nil

        var fourthCert: ExtendedCBORWebToken = CBORWebToken
            .mockVaccinationCertificate
            .mockVaccinationUVCI("4")
            .mockVaccinationSetDate(vacinationDateLate)
            .extended(vaccinationQRCodeData:"4")
        fourthCert.vaccinationCertificate.iat = nil
        
        var fifthCert: ExtendedCBORWebToken = CBORWebToken
            .mockVaccinationCertificate
            .mockVaccinationUVCI("5")
            .mockVaccinationSetDate(vacinationDateLate)
            .extended(vaccinationQRCodeData:"5")
        fifthCert.vaccinationCertificate.iat = nil

        let certificates = [
            secondCert,
            firstCert,
            fifthCert,
            thirdCert,
            fourthCert
        ]
        
        // WHEN
        let sortedCertifiates = certificates.sortLatest()

        // THEN
        XCTAssertEqual(sortedCertifiates.count, 5)
        XCTAssertEqual(sortedCertifiates[0].vaccinationCertificate.hcert.dgc.uvci, "2")
    }
    
    func testSortingVacBasedOnIatAndWithCertWhereIatIsNilAndOneCertificateIsNotPosNotPcrWithIat() throws {
        // GIVEN
        let vacinationDate = DateUtils.parseDate("2021-04-26T15:05:00")!
        let vacinationDateLate = DateUtils.parseDate("2021-04-27T15:05:00")!
        let testDateYesterday = Date().addingTimeInterval(-86400)
        var firstCert: ExtendedCBORWebToken = CBORWebToken
            .mockVaccinationCertificate
            .mockVaccinationUVCI("1")
            .mockVaccinationSetDate(vacinationDate)
            .extended(vaccinationQRCodeData:"1")
        firstCert.vaccinationCertificate.iat = DateUtils.parseDate("2021-04-26T15:05:00")

        var secondCert: ExtendedCBORWebToken = CBORWebToken
            .mockVaccinationCertificate
            .mockVaccinationUVCI("2")
            .mockVaccinationSetDate(vacinationDate)
            .extended(vaccinationQRCodeData:"2")
        secondCert.vaccinationCertificate.iat = DateUtils.parseDate("2021-04-27T15:05:00")

        var thirdCert: ExtendedCBORWebToken = CBORWebToken
            .mockVaccinationCertificate
            .mockVaccinationUVCI("3")
            .mockVaccinationSetDate(vacinationDate)
            .extended(vaccinationQRCodeData:"3")
        thirdCert.vaccinationCertificate.iat = DateUtils.parseDate("2021-04-28T15:05:00")

        var fourthCert: ExtendedCBORWebToken = CBORWebToken
            .mockVaccinationCertificate
            .mockVaccinationUVCI("4")
            .mockVaccinationSetDate(vacinationDate)
            .extended(vaccinationQRCodeData:"4")
        fourthCert.vaccinationCertificate.iat = nil
        
        var fifthCert: ExtendedCBORWebToken = CBORWebToken
            .mockVaccinationCertificate
            .mockVaccinationUVCI("5")
            .mockVaccinationSetDate(vacinationDateLate)
            .extended(vaccinationQRCodeData:"5")
        fifthCert.vaccinationCertificate.iat = nil
        
        var sixtCert: ExtendedCBORWebToken = CBORWebToken
            .mockTestCertificate
            .mockTestUVCI("6")
            .extended(vaccinationQRCodeData:"6")
        sixtCert.vaccinationCertificate.hcert.dgc.t!.first!.tt = "NOT PCR"
        sixtCert.vaccinationCertificate.hcert.dgc.t!.first!.tr = "NOT POSTIIVE"
        sixtCert.vaccinationCertificate.hcert.dgc.t!.first!.sc = testDateYesterday
        sixtCert.vaccinationCertificate.iat = nil

        var seventhCert: ExtendedCBORWebToken = CBORWebToken
            .mockTestCertificate
            .mockTestUVCI("7")
            .extended(vaccinationQRCodeData:"7")
        seventhCert.vaccinationCertificate.hcert.dgc.t!.first!.tt = "NOT PCR"
        seventhCert.vaccinationCertificate.hcert.dgc.t!.first!.tr = "NOT POSTIIVE"
        seventhCert.vaccinationCertificate.hcert.dgc.t!.first!.sc = testDateYesterday
        seventhCert.vaccinationCertificate.iat = testDateYesterday

        let certificates = [
            secondCert,
            firstCert,
            fifthCert,
            sixtCert,
            seventhCert,
            thirdCert,
            fourthCert
        ]
        
        // WHEN
        let sortedCertifiates = certificates.sortLatest()

        // THEN
        XCTAssertEqual(sortedCertifiates.count, 7)
        XCTAssertEqual(sortedCertifiates[0].vaccinationCertificate.hcert.dgc.uvci, "7")
    }

    func testSortLatest_booster_order() {
        // Given
        let sut = [
            CBORWebToken.mockVaccinationCertificate.doseNumber(3).extended(),
            CBORWebToken.mockVaccinationCertificate.doseNumber(1).extended(),
            CBORWebToken.mockVaccinationCertificate.doseNumber(4).extended(),
            CBORWebToken.mockVaccinationCertificate.doseNumber(2).extended()
        ]

        // When
        let tokens = sut.sortLatest()

        // Then
        guard tokens.count > 3 else {
            XCTFail("Number of tokens must be bigger 3.")
            return
        }
        XCTAssertEqual(tokens[0].vaccinationCertificate.hcert.dgc.v!.first!.dn, 4)
        XCTAssertEqual(tokens[1].vaccinationCertificate.hcert.dgc.v?.first?.dn, 3)
        XCTAssertEqual(tokens[2].vaccinationCertificate.hcert.dgc.v?.first?.dn, 2)
        XCTAssertEqual(tokens[3].vaccinationCertificate.hcert.dgc.v?.first?.dn, 1)
    }
    
    func testFilter() throws {
        // GIVEN
        let dateOfBirthString = "2021-04-26T15:05:00"
        let dateOfBirth = DateUtils.parseDate(dateOfBirthString)
        var firstCert: ExtendedCBORWebToken = CBORWebToken.mockVaccinationCertificate.extended()
        firstCert.vaccinationCertificate.hcert.dgc.dob = dateOfBirth
        firstCert.vaccinationCertificate.hcert.dgc.dobString = dateOfBirthString

        let secondCert: ExtendedCBORWebToken = CBORWebToken.mockVaccinationCertificate.extended()
        let thirdCert: ExtendedCBORWebToken = CBORWebToken.mockVaccinationCertificate.extended()
        let fourthCert: ExtendedCBORWebToken = CBORWebToken.mockVaccinationCertificate.extended()
        let fifthCert: ExtendedCBORWebToken = CBORWebToken.mockVaccinationCertificate.extended()
        let sixtCert: ExtendedCBORWebToken = CBORWebToken.mockTestCertificate.extended()
        let seventhCert: ExtendedCBORWebToken = CBORWebToken.mockTestCertificate.extended()

        let certificates = [
            secondCert,
            firstCert,
            fifthCert,
            sixtCert,
            seventhCert,
            thirdCert,
            fourthCert
        ]
        
        // WHEN
        let sortedCertifiates = certificates.filter(types: [.vaccination],
                                                    givenName: "DOE",
                                                    familyName: "JOHN",
                                                    dob: dateOfBirthString)

        // THEN
        XCTAssertEqual(sortedCertifiates.count, 1)
        XCTAssertEqual(sortedCertifiates.first, firstCert)
    }
    
    func testFilterMatchingAllVaccination() throws {
        // GIVEN
        let firstCert: ExtendedCBORWebToken = CBORWebToken.mockVaccinationCertificate.extended()
        let secondCert: ExtendedCBORWebToken = CBORWebToken.mockVaccinationCertificate.extended()
        let thirdCert: ExtendedCBORWebToken = CBORWebToken.mockVaccinationCertificate.extended()
        let fourthCert: ExtendedCBORWebToken = CBORWebToken.mockVaccinationCertificate.extended()
        let fifthCert: ExtendedCBORWebToken = CBORWebToken.mockVaccinationCertificate.extended()
        let sixtCert: ExtendedCBORWebToken = CBORWebToken.mockTestCertificate.extended()
        let seventhCert: ExtendedCBORWebToken = CBORWebToken.mockTestCertificate.extended()

        let certificates = [
            secondCert,
            firstCert,
            fifthCert,
            sixtCert,
            seventhCert,
            thirdCert,
            fourthCert
        ]
        
        // WHEN
        let sortedCertifiates = certificates.filter(types: [.vaccination],
                                                    givenName: "DOE",
                                                    familyName: "JOHN",
                                                    dob: "1990-01-01")

        // THEN
        XCTAssertEqual(sortedCertifiates.count, 5)
    }
    
    func testFilterMatchingAllTests() throws {
        // GIVEN
        let firstCert: ExtendedCBORWebToken = CBORWebToken.mockVaccinationCertificate.extended()
        let secondCert: ExtendedCBORWebToken = CBORWebToken.mockVaccinationCertificate.extended()
        let thirdCert: ExtendedCBORWebToken = CBORWebToken.mockVaccinationCertificate.extended()
        let fourthCert: ExtendedCBORWebToken = CBORWebToken.mockVaccinationCertificate.extended()
        let fifthCert: ExtendedCBORWebToken = CBORWebToken.mockVaccinationCertificate.extended()
        let sixtCert: ExtendedCBORWebToken = CBORWebToken.mockTestCertificate.extended()
        let seventhCert: ExtendedCBORWebToken = CBORWebToken.mockTestCertificate.extended()

        let certificates = [
            secondCert,
            firstCert,
            fifthCert,
            sixtCert,
            seventhCert,
            thirdCert,
            fourthCert
        ]
        
        // WHEN
        let sortedCertifiates = certificates.filter(types: [.test],
                                                    givenName: "DOE",
                                                    familyName: "JOHN",
                                                    dob: "1990-01-01")

        // THEN
        XCTAssertEqual(sortedCertifiates.count, 2)
    }
    
    func testFilterMatchingAllRecoveries() throws {
        // GIVEN
        let firstCert: ExtendedCBORWebToken = CBORWebToken.mockVaccinationCertificate.extended()
        let secondCert: ExtendedCBORWebToken = CBORWebToken.mockVaccinationCertificate.extended()
        let thirdCert: ExtendedCBORWebToken = CBORWebToken.mockVaccinationCertificate.extended()
        let fourthCert: ExtendedCBORWebToken = CBORWebToken.mockVaccinationCertificate.extended()
        let fifthCert: ExtendedCBORWebToken = CBORWebToken.mockVaccinationCertificate.extended()
        let sixtCert: ExtendedCBORWebToken = CBORWebToken.mockTestCertificate.extended()
        let seventhCert: ExtendedCBORWebToken = CBORWebToken.mockTestCertificate.extended()
        let eightCert: ExtendedCBORWebToken = CBORWebToken.mockRecoveryCertificate.extended()

        let certificates = [
            secondCert,
            firstCert,
            fifthCert,
            sixtCert,
            eightCert,
            seventhCert,
            thirdCert,
            fourthCert
        ]
        
        // WHEN
        let sortedCertifiates = certificates.filter(types: [.recovery],
                                                    givenName: "DOE",
                                                    familyName: "JOHN",
                                                    dob: "1990-01-01")

        // THEN
        XCTAssertEqual(sortedCertifiates.count, 1)
    }
    
    func testFilterMissingDob() throws {
        // GIVEN
        let firstCert: ExtendedCBORWebToken = CBORWebToken.mockVaccinationCertificate.extended()
        let secondCert: ExtendedCBORWebToken = CBORWebToken.mockVaccinationCertificate.extended()
        let thirdCert: ExtendedCBORWebToken = CBORWebToken.mockVaccinationCertificate.extended()
        let fourthCert: ExtendedCBORWebToken = CBORWebToken.mockVaccinationCertificate.extended()
        let fifthCert: ExtendedCBORWebToken = CBORWebToken.mockVaccinationCertificate.extended()
        let sixtCert: ExtendedCBORWebToken = CBORWebToken.mockTestCertificate.extended()
        let seventhCert: ExtendedCBORWebToken = CBORWebToken.mockTestCertificate.extended()

        let certificates = [
            secondCert,
            firstCert,
            fifthCert,
            sixtCert,
            seventhCert,
            thirdCert,
            fourthCert
        ]
        
        // WHEN
        let sortedCertifiates = certificates.filter(types: [.vaccination],
                                                    givenName: "DOE",
                                                    familyName: "JOHN",
                                                    dob: "")

        // THEN
        XCTAssertEqual(sortedCertifiates.count, 0)
    }
    
    func testFilterMissingGivenName() throws {
        // GIVEN
        let firstCert: ExtendedCBORWebToken = CBORWebToken.mockVaccinationCertificate.extended()
        let secondCert: ExtendedCBORWebToken = CBORWebToken.mockVaccinationCertificate.extended()
        let thirdCert: ExtendedCBORWebToken = CBORWebToken.mockVaccinationCertificate.extended()
        let fourthCert: ExtendedCBORWebToken = CBORWebToken.mockVaccinationCertificate.extended()
        let fifthCert: ExtendedCBORWebToken = CBORWebToken.mockVaccinationCertificate.extended()
        let sixtCert: ExtendedCBORWebToken = CBORWebToken.mockTestCertificate.extended()
        let seventhCert: ExtendedCBORWebToken = CBORWebToken.mockTestCertificate.extended()
        let eightCert: ExtendedCBORWebToken = CBORWebToken.mockRecoveryCertificate.extended()

        let certificates = [
            secondCert,
            firstCert,
            fifthCert,
            sixtCert,
            eightCert,
            seventhCert,
            thirdCert,
            fourthCert
        ]
        
        // WHEN
        let sortedCertifiates = certificates.filter(types: [.recovery],
                                                    givenName: "",
                                                    familyName: "JOHN",
                                                    dob: "1990-01-01")

        // THEN
        XCTAssertEqual(sortedCertifiates.count, 0)
    }
    
    func testFilterMissingFamilyNameName() throws {
        // GIVEN
        let firstCert: ExtendedCBORWebToken = CBORWebToken.mockVaccinationCertificate.extended()
        let secondCert: ExtendedCBORWebToken = CBORWebToken.mockVaccinationCertificate.extended()
        let thirdCert: ExtendedCBORWebToken = CBORWebToken.mockVaccinationCertificate.extended()
        let fourthCert: ExtendedCBORWebToken = CBORWebToken.mockVaccinationCertificate.extended()
        let fifthCert: ExtendedCBORWebToken = CBORWebToken.mockVaccinationCertificate.extended()
        let sixtCert: ExtendedCBORWebToken = CBORWebToken.mockTestCertificate.extended()
        let seventhCert: ExtendedCBORWebToken = CBORWebToken.mockTestCertificate.extended()
        let eightCert: ExtendedCBORWebToken = CBORWebToken.mockRecoveryCertificate.extended()

        let certificates = [
            secondCert,
            firstCert,
            fifthCert,
            sixtCert,
            eightCert,
            seventhCert,
            thirdCert,
            fourthCert
        ]
        
        // WHEN
        let sortedCertifiates = certificates.filter(types: [.vaccination],
                                                    givenName: "DOE",
                                                    familyName: "",
                                                    dob: "1990-01-01")

        // THEN
        XCTAssertEqual(sortedCertifiates.count, 0)
    }
    
    func testFilterMissingAllVariables() throws {
        // GIVEN
        let firstCert: ExtendedCBORWebToken = CBORWebToken.mockVaccinationCertificate.extended()
        let secondCert: ExtendedCBORWebToken = CBORWebToken.mockVaccinationCertificate.extended()
        let thirdCert: ExtendedCBORWebToken = CBORWebToken.mockVaccinationCertificate.extended()
        let fourthCert: ExtendedCBORWebToken = CBORWebToken.mockVaccinationCertificate.extended()
        let fifthCert: ExtendedCBORWebToken = CBORWebToken.mockVaccinationCertificate.extended()
        let sixtCert: ExtendedCBORWebToken = CBORWebToken.mockTestCertificate.extended()
        let seventhCert: ExtendedCBORWebToken = CBORWebToken.mockTestCertificate.extended()
        let eightCert: ExtendedCBORWebToken = CBORWebToken.mockRecoveryCertificate.extended()

        let certificates = [
            secondCert,
            firstCert,
            fifthCert,
            sixtCert,
            eightCert,
            seventhCert,
            thirdCert,
            fourthCert
        ]
        
        // WHEN
        let sortedCertifiates = certificates.filter(types: [.vaccination],
                                                    givenName: "",
                                                    familyName: "",
                                                    dob: "")

        // THEN
        XCTAssertEqual(sortedCertifiates.count, 0)
    }
    
    func testFilterMissingSeveralPersonsCertificates() throws {
        // GIVEN
        let firstCert: ExtendedCBORWebToken = CBORWebToken.mockVaccinationCertificate.extended()
        firstCert.vaccinationCertificate.hcert.dgc.nam.fnt = "Person 1"
        firstCert.vaccinationCertificate.hcert.dgc.nam.gnt = "Person 1"
        let secondCert: ExtendedCBORWebToken = CBORWebToken.mockVaccinationCertificate.extended()
        let thirdCert: ExtendedCBORWebToken = CBORWebToken.mockVaccinationCertificate.extended()
        thirdCert.vaccinationCertificate.hcert.dgc.nam.fnt = "Person 2"
        thirdCert.vaccinationCertificate.hcert.dgc.nam.gnt = "Person 2"
        let fourthCert: ExtendedCBORWebToken = CBORWebToken.mockVaccinationCertificate.extended()
        let fifthCert: ExtendedCBORWebToken = CBORWebToken.mockVaccinationCertificate.extended()
        let sixtCert: ExtendedCBORWebToken = CBORWebToken.mockTestCertificate.extended()
        let seventhCert: ExtendedCBORWebToken = CBORWebToken.mockTestCertificate.extended()
        let eightCert: ExtendedCBORWebToken = CBORWebToken.mockRecoveryCertificate.extended()
        eightCert.vaccinationCertificate.hcert.dgc.nam.fnt = "Person 2"
        eightCert.vaccinationCertificate.hcert.dgc.nam.gnt = "Person 2"

        let certificates = [
            secondCert,
            firstCert,
            fifthCert,
            sixtCert,
            eightCert,
            seventhCert,
            thirdCert,
            fourthCert
        ]
        
        // WHEN
        let sortedCertifiates = certificates.filter(types: [.vaccination],
                                                    givenName: "DOE",
                                                    familyName: "JOHN",
                                                    dob: "1990-01-01")

        // THEN
        XCTAssertEqual(sortedCertifiates.count, 3)
        XCTAssertEqual(sortedCertifiates.first, secondCert)
    }
    
    func testFilterMissingSeveralPersonsCertificatesDifferentArrayOrder() throws {
        // GIVEN
        let firstCert: ExtendedCBORWebToken = CBORWebToken.mockVaccinationCertificate.extended()
        firstCert.vaccinationCertificate.hcert.dgc.nam.fnt = "Person 1"
        firstCert.vaccinationCertificate.hcert.dgc.nam.gnt = "Person 1"
        let secondCert: ExtendedCBORWebToken = CBORWebToken.mockVaccinationCertificate.extended()
        let thirdCert: ExtendedCBORWebToken = CBORWebToken.mockVaccinationCertificate.extended()
        thirdCert.vaccinationCertificate.hcert.dgc.nam.fnt = "Person 2"
        thirdCert.vaccinationCertificate.hcert.dgc.nam.gnt = "Person 2"
        let fourthCert: ExtendedCBORWebToken = CBORWebToken.mockVaccinationCertificate.extended()
        let fifthCert: ExtendedCBORWebToken = CBORWebToken.mockVaccinationCertificate.extended()
        let sixtCert: ExtendedCBORWebToken = CBORWebToken.mockTestCertificate.extended()
        let seventhCert: ExtendedCBORWebToken = CBORWebToken.mockTestCertificate.extended()
        let eightCert: ExtendedCBORWebToken = CBORWebToken.mockRecoveryCertificate.extended()
        eightCert.vaccinationCertificate.hcert.dgc.nam.fnt = "Person 2"
        eightCert.vaccinationCertificate.hcert.dgc.nam.gnt = "Person 2"

        let certificates = [
            firstCert,
            fifthCert,
            sixtCert,
            eightCert,
            seventhCert,
            thirdCert,
            fourthCert,
            secondCert
        ]
        
        // WHEN
        let sortedCertifiates = certificates.filter(types: [.vaccination],
                                                    givenName: "DOE",
                                                    familyName: "JOHN",
                                                    dob: "1990-01-01")

        // THEN
        XCTAssertEqual(sortedCertifiates.count, 3)
        XCTAssertEqual(sortedCertifiates[0], secondCert)
        XCTAssertEqual(sortedCertifiates[1], fifthCert)
        XCTAssertEqual(sortedCertifiates[2], fourthCert)
    }
    
    func testFilterVacAndRequestRecAlsoWhereNotMatchBecuaseofPerson() throws {
        // GIVEN
        let firstCert: ExtendedCBORWebToken = CBORWebToken.mockVaccinationCertificate.extended()
        firstCert.vaccinationCertificate.hcert.dgc.nam.fnt = "Person 1"
        firstCert.vaccinationCertificate.hcert.dgc.nam.gnt = "Person 1"
        let secondCert: ExtendedCBORWebToken = CBORWebToken.mockVaccinationCertificate.extended()
        let thirdCert: ExtendedCBORWebToken = CBORWebToken.mockVaccinationCertificate.extended()
        thirdCert.vaccinationCertificate.hcert.dgc.nam.fnt = "Person 2"
        thirdCert.vaccinationCertificate.hcert.dgc.nam.gnt = "Person 2"
        let fourthCert: ExtendedCBORWebToken = CBORWebToken.mockVaccinationCertificate.extended()
        let fifthCert: ExtendedCBORWebToken = CBORWebToken.mockVaccinationCertificate.extended()
        let sixtCert: ExtendedCBORWebToken = CBORWebToken.mockTestCertificate.extended()
        let seventhCert: ExtendedCBORWebToken = CBORWebToken.mockTestCertificate.extended()
        let eightCert: ExtendedCBORWebToken = CBORWebToken.mockRecoveryCertificate.extended()
        eightCert.vaccinationCertificate.hcert.dgc.nam.fnt = "Person 2"
        eightCert.vaccinationCertificate.hcert.dgc.nam.gnt = "Person 2"

        let certificates = [
            firstCert,
            fifthCert,
            sixtCert,
            eightCert,
            seventhCert,
            thirdCert,
            fourthCert,
            secondCert
        ]
        
        // WHEN
        let sortedCertifiates = certificates.filter(types: [.vaccination, .recovery],
                                                    givenName: "DOE",
                                                    familyName: "JOHN",
                                                    dob: "1990-01-01")

        // THEN
        XCTAssertEqual(sortedCertifiates.count, 3)
        XCTAssertEqual(sortedCertifiates[0], secondCert)
        XCTAssertEqual(sortedCertifiates[1], fifthCert)
        XCTAssertEqual(sortedCertifiates[2], fourthCert)
    }
    
    func testFilterVacAndRec() throws {
        // GIVEN
        let firstCert: ExtendedCBORWebToken = CBORWebToken.mockVaccinationCertificate.extended()
        firstCert.vaccinationCertificate.hcert.dgc.nam.fnt = "Person 1"
        firstCert.vaccinationCertificate.hcert.dgc.nam.gnt = "Person 1"
        let secondCert: ExtendedCBORWebToken = CBORWebToken.mockVaccinationCertificate.extended()
        let thirdCert: ExtendedCBORWebToken = CBORWebToken.mockVaccinationCertificate.extended()
        thirdCert.vaccinationCertificate.hcert.dgc.nam.fnt = "Person 2"
        thirdCert.vaccinationCertificate.hcert.dgc.nam.gnt = "Person 2"
        let fourthCert: ExtendedCBORWebToken = CBORWebToken.mockVaccinationCertificate.extended()
        let fifthCert: ExtendedCBORWebToken = CBORWebToken.mockVaccinationCertificate.extended()
        let sixtCert: ExtendedCBORWebToken = CBORWebToken.mockTestCertificate.extended()
        let seventhCert: ExtendedCBORWebToken = CBORWebToken.mockTestCertificate.extended()
        let eightCert: ExtendedCBORWebToken = CBORWebToken.mockRecoveryCertificate.extended()

        let certificates = [
            firstCert,
            fifthCert,
            sixtCert,
            eightCert,
            seventhCert,
            thirdCert,
            fourthCert,
            secondCert
        ]
        
        // WHEN
        let sortedCertifiates = certificates.filter(types: [.vaccination, .recovery],
                                                    givenName: "DOE",
                                                    familyName: "JOHN",
                                                    dob: "1990-01-01")

        // THEN
        XCTAssertEqual(sortedCertifiates.count, 4)
        
        XCTAssertEqual(sortedCertifiates[0], secondCert)
        XCTAssertNotNil(sortedCertifiates[0].firstVaccination)
        XCTAssertNil(sortedCertifiates[0].firstTest)
        XCTAssertNil(sortedCertifiates[0].firstRecovery)
        
        XCTAssertEqual(sortedCertifiates[1], fifthCert)
        XCTAssertNotNil(sortedCertifiates[1].firstVaccination)
        XCTAssertNil(sortedCertifiates[1].firstTest)
        XCTAssertNil(sortedCertifiates[1].firstRecovery)
        
        XCTAssertEqual(sortedCertifiates[2], fourthCert)
        XCTAssertNotNil(sortedCertifiates[2].firstVaccination)
        XCTAssertNil(sortedCertifiates[2].firstTest)
        XCTAssertNil(sortedCertifiates[2].firstRecovery)
        
        XCTAssertEqual(sortedCertifiates[3], eightCert)
        XCTAssertNil(sortedCertifiates[3].firstVaccination)
        XCTAssertNil(sortedCertifiates[3].firstTest)
        XCTAssertNotNil(sortedCertifiates[3].firstRecovery)
    }
    
    func testFilterVacRecTest() throws {
        // GIVEN
        let firstCert: ExtendedCBORWebToken = CBORWebToken.mockVaccinationCertificate.extended()
        firstCert.vaccinationCertificate.hcert.dgc.nam.fnt = "Person 1"
        firstCert.vaccinationCertificate.hcert.dgc.nam.gnt = "Person 1"
        let secondCert: ExtendedCBORWebToken = CBORWebToken.mockVaccinationCertificate.extended()
        let thirdCert: ExtendedCBORWebToken = CBORWebToken.mockVaccinationCertificate.extended()
        thirdCert.vaccinationCertificate.hcert.dgc.nam.fnt = "Person 2"
        thirdCert.vaccinationCertificate.hcert.dgc.nam.gnt = "Person 2"
        let fourthCert: ExtendedCBORWebToken = CBORWebToken.mockVaccinationCertificate.extended()
        let fifthCert: ExtendedCBORWebToken = CBORWebToken.mockVaccinationCertificate.extended()
        let sixtCert: ExtendedCBORWebToken = CBORWebToken.mockTestCertificate.extended()
        let seventhCert: ExtendedCBORWebToken = CBORWebToken.mockTestCertificate.extended()
        let eightCert: ExtendedCBORWebToken = CBORWebToken.mockRecoveryCertificate.extended()
        eightCert.vaccinationCertificate.hcert.dgc.nam.fnt = "Person 2"
        eightCert.vaccinationCertificate.hcert.dgc.nam.gnt = "Person 2"

        let certificates = [
            firstCert,
            fifthCert,
            sixtCert,
            eightCert,
            seventhCert,
            thirdCert,
            fourthCert,
            secondCert
        ]
        
        // WHEN
        let sortedCertifiates = certificates.filter(types: [.vaccination, .recovery, .test],
                                                    givenName: "DOE",
                                                    familyName: "JOHN",
                                                    dob: "1990-01-01")

        // THEN
        XCTAssertEqual(sortedCertifiates.count, 5)
        
        XCTAssertEqual(sortedCertifiates[0], secondCert)
        XCTAssertNotNil(sortedCertifiates[0].firstVaccination)
        XCTAssertNil(sortedCertifiates[0].firstTest)
        XCTAssertNil(sortedCertifiates[0].firstRecovery)
        
        XCTAssertEqual(sortedCertifiates[1], fifthCert)
        XCTAssertNotNil(sortedCertifiates[1].firstVaccination)
        XCTAssertNil(sortedCertifiates[1].firstTest)
        XCTAssertNil(sortedCertifiates[1].firstRecovery)
        
        XCTAssertEqual(sortedCertifiates[2], fourthCert)
        XCTAssertNotNil(sortedCertifiates[2].firstVaccination)
        XCTAssertNil(sortedCertifiates[2].firstTest)
        XCTAssertNil(sortedCertifiates[2].firstRecovery)
        
        XCTAssertEqual(sortedCertifiates[3], sixtCert)
        XCTAssertNil(sortedCertifiates[3].firstVaccination)
        XCTAssertNotNil(sortedCertifiates[3].firstTest)
        XCTAssertNil(sortedCertifiates[3].firstRecovery)
        
        XCTAssertEqual(sortedCertifiates[4], seventhCert)
        XCTAssertNil(sortedCertifiates[4].firstVaccination)
        XCTAssertNotNil(sortedCertifiates[4].firstTest)
        XCTAssertNil(sortedCertifiates[4].firstRecovery)
    }
    
    func testFilterVacRecTestAllSamePerson() throws {
        // GIVEN
        let firstCert: ExtendedCBORWebToken = CBORWebToken.mockVaccinationCertificate.mockVaccinationUVCI("1").extended()
        let secondCert: ExtendedCBORWebToken = CBORWebToken.mockVaccinationCertificate.mockVaccinationUVCI("2").extended()
        let thirdCert: ExtendedCBORWebToken = CBORWebToken.mockVaccinationCertificate.mockVaccinationUVCI("3").extended()
        let fourthCert: ExtendedCBORWebToken = CBORWebToken.mockVaccinationCertificate.mockVaccinationUVCI("4").extended()
        let fifthCert: ExtendedCBORWebToken = CBORWebToken.mockVaccinationCertificate.mockVaccinationUVCI("5").extended()
        let sixtCert: ExtendedCBORWebToken = CBORWebToken.mockTestCertificate.mockTestUVCI("6").extended()
        let seventhCert: ExtendedCBORWebToken = CBORWebToken.mockTestCertificate.mockTestUVCI("7").extended()
        let eightCert: ExtendedCBORWebToken = CBORWebToken.mockRecoveryCertificate.mockRecoveryUVCI("8").extended()

        let certificates = [
            firstCert,
            fifthCert,
            sixtCert,
            eightCert,
            seventhCert,
            thirdCert,
            fourthCert,
            secondCert
        ]
        
        // WHEN
        let sortedCertifiates = certificates.filter(types: [.vaccination, .recovery, .test],
                                                    givenName: "DOE",
                                                    familyName: "JOHN",
                                                    dob: "1990-01-01")

        // THEN
        XCTAssertEqual(sortedCertifiates.count, 8)
        
        XCTAssertEqual(sortedCertifiates[0].vaccinationCertificate.hcert.dgc.uvci, firstCert.vaccinationCertificate.hcert.dgc.uvci)
        XCTAssertEqual(sortedCertifiates[1].vaccinationCertificate.hcert.dgc.uvci, fifthCert.vaccinationCertificate.hcert.dgc.uvci)
        XCTAssertEqual(sortedCertifiates[2].vaccinationCertificate.hcert.dgc.uvci, thirdCert.vaccinationCertificate.hcert.dgc.uvci)
        XCTAssertEqual(sortedCertifiates[3].vaccinationCertificate.hcert.dgc.uvci, fourthCert.vaccinationCertificate.hcert.dgc.uvci)
        XCTAssertEqual(sortedCertifiates[4].vaccinationCertificate.hcert.dgc.uvci, secondCert.vaccinationCertificate.hcert.dgc.uvci)
        XCTAssertEqual(sortedCertifiates[5].vaccinationCertificate.hcert.dgc.uvci, eightCert.vaccinationCertificate.hcert.dgc.uvci)
        XCTAssertEqual(sortedCertifiates[6].vaccinationCertificate.hcert.dgc.uvci, sixtCert.vaccinationCertificate.hcert.dgc.uvci)
        XCTAssertEqual(sortedCertifiates[7].vaccinationCertificate.hcert.dgc.uvci, seventhCert.vaccinationCertificate.hcert.dgc.uvci)


        
        XCTAssertNotNil(sortedCertifiates[0].firstVaccination)
        XCTAssertNil(sortedCertifiates[0].firstTest)
        XCTAssertNil(sortedCertifiates[0].firstRecovery)
        
        XCTAssertNotNil(sortedCertifiates[1].firstVaccination)
        XCTAssertNil(sortedCertifiates[1].firstTest)
        XCTAssertNil(sortedCertifiates[1].firstRecovery)
        
        XCTAssertNotNil(sortedCertifiates[2].firstVaccination)
        XCTAssertNil(sortedCertifiates[2].firstTest)
        XCTAssertNil(sortedCertifiates[2].firstRecovery)
        
        XCTAssertNotNil(sortedCertifiates[3].firstVaccination)
        XCTAssertNil(sortedCertifiates[3].firstTest)
        XCTAssertNil(sortedCertifiates[3].firstRecovery)
        
        XCTAssertNotNil(sortedCertifiates[4].firstVaccination)
        XCTAssertNil(sortedCertifiates[4].firstTest)
        XCTAssertNil(sortedCertifiates[4].firstRecovery)
        
        XCTAssertNil(sortedCertifiates[5].firstVaccination)
        XCTAssertNil(sortedCertifiates[5].firstTest)
        XCTAssertNotNil(sortedCertifiates[5].firstRecovery)
        
        XCTAssertNil(sortedCertifiates[6].firstVaccination)
        XCTAssertNotNil(sortedCertifiates[6].firstTest)
        XCTAssertNil(sortedCertifiates[6].firstRecovery)
        
        XCTAssertNil(sortedCertifiates[7].firstVaccination)
        XCTAssertNotNil(sortedCertifiates[7].firstTest)
        XCTAssertNil(sortedCertifiates[7].firstRecovery)
    }
}
