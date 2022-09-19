//
//  Array+ExtendedCBORWebTokenTests.swift
//  
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassCommon
import XCTest

class ArrayExtendedCBORWebTokenTests: XCTestCase {
    
    var singleDoseImmunizationJohnsonCert = CBORWebToken.mockVaccinationCertificate
        .mockVaccinationUVCI("1")
        .medicalProduct(.johnsonjohnson)
        .doseNumber(1)
        .seriesOfDoses(1)
        .extended(vaccinationQRCodeData: "1")
    var doubleDoseImmunizationJohnsonCert = CBORWebToken.mockVaccinationCertificate
        .mockVaccinationUVCI("1")
        .medicalProduct(.johnsonjohnson)
        .doseNumber(2)
        .seriesOfDoses(2)
        .extended(vaccinationQRCodeData: "1")
    var vaccinationWithTwoShotsOfVaccine = CBORWebToken.mockVaccinationCertificate
        .mockVaccinationUVCI("2")
        .medicalProduct(.biontech)
        .doseNumber(2)
        .seriesOfDoses(2)
        .extended(vaccinationQRCodeData: "2")
    let recoveryCert = CBORWebToken.mockRecoveryCertificate
        .mockRecoveryUVCI("3")
        .extended(vaccinationQRCodeData: "3")
    var someOtherCert1 = CBORWebToken.mockVaccinationCertificate
        .mockVaccinationUVCI("4")
        .medicalProduct(.biontech)
        .doseNumber(1)
        .seriesOfDoses(2)
        .extended(vaccinationQRCodeData: "4")
    var someOtherCert2 = CBORWebToken.mockTestCertificate
        .mockTestUVCI("5")
        .extended(vaccinationQRCodeData: "5")
    let recoveryCert2 = CBORWebToken.mockRecoveryCertificate
        .mockRecoveryUVCI("6")
        .extended(vaccinationQRCodeData: "6")
    let boosterCertificateAfterReIssue = CBORWebToken.mockVaccinationCertificate
        .mockVaccinationUVCI("7")
        .medicalProduct(.biontech)
        .doseNumber(2)
        .seriesOfDoses(1)
        .extended(vaccinationQRCodeData: "7")
    
    func testPartitionedByOwner_empty() {
        // Given
        let sut: [ExtendedCBORWebToken] = []
        
        // When
        let partitions = sut.partitionedByOwner
        
        // Then
        XCTAssertTrue(partitions.isEmpty)
    }
    
    func testPartitionedByOwner() {
        // Given
        var token1Owner1 = CBORWebToken.mockVaccinationCertificate
        var token2Owner1 = CBORWebToken.mockVaccinationCertificate
        var tokenOwner2 = CBORWebToken.mockVaccinationCertificate
        var tokenOwner3 = CBORWebToken.mockVaccinationCertificate
        token1Owner1.hcert.dgc = .mock(name: .mustermann())
        token2Owner1.hcert.dgc = .mock(name: .mustermann())
        tokenOwner2.hcert.dgc = .mock(name: .yildirim())
        tokenOwner3.hcert.dgc = .mock(name: .mustermann(), dob: Date())
        let sut = [
            token1Owner1.extended(),
            token2Owner1.extended(),
            tokenOwner2.extended(),
            tokenOwner3.extended()
        ]
        
        // When
        let partitions = sut.partitionedByOwner
        
        // Then
        XCTAssertEqual(partitions.count, 3)
        if partitions.count > 2 {
            XCTAssertTrue(
                (partitions[0].count == 2 && partitions[1].count == 1 && partitions[2].count == 1) ||
                (partitions[0].count == 1 && partitions[1].count == 2 && partitions[2].count == 1) ||
                (partitions[0].count == 1 && partitions[1].count == 1 && partitions[2].count == 2) 
            )
        }
    }
    
    func testBosterAfterOneShotImmunization() {
        // GIVEN
        let certs = [someOtherCert2,
                     singleDoseImmunizationJohnsonCert,
                     someOtherCert1,
                     vaccinationWithTwoShotsOfVaccine]
        
        // WHEN
        let candidateForReissue = certs.filterBoosterAfterVaccinationAfterRecoveryFromGermany
        
        // THEN
        XCTAssertFalse(candidateForReissue.isEmpty)
        XCTAssertTrue(candidateForReissue.count == 2)
        XCTAssertTrue(candidateForReissue.contains(singleDoseImmunizationJohnsonCert))
        XCTAssertTrue(candidateForReissue.contains(vaccinationWithTwoShotsOfVaccine))
        XCTAssertFalse(candidateForReissue.contains(someOtherCert1))
        XCTAssertFalse(candidateForReissue.contains(someOtherCert2))
    }
    
    func testBoosteredWithJohnsonAlreadyButRecoveryIsFresherDateThanVaccinations() {
        // GIVEN
        let certs = [recoveryCert,
                     singleDoseImmunizationJohnsonCert,
                     doubleDoseImmunizationJohnsonCert,
                     someOtherCert1]
        
        // WHEN
        let candidateForReissue = certs.filterBoosterAfterVaccinationAfterRecoveryFromGermany
        
        // THEN
        XCTAssertTrue(certs.qualifiedForReissue)
        XCTAssertFalse(candidateForReissue.isEmpty)
        XCTAssertEqual(candidateForReissue.count, 2)
        XCTAssertTrue(candidateForReissue.contains(singleDoseImmunizationJohnsonCert))
        XCTAssertTrue(candidateForReissue.contains(doubleDoseImmunizationJohnsonCert))
        XCTAssertFalse(candidateForReissue.contains(recoveryCert))
        XCTAssertFalse(candidateForReissue.contains(someOtherCert1))
        XCTAssertFalse(candidateForReissue.contains(someOtherCert2))
    }
    
    func testBoosteredWithJohnsonAlreadyAndRecoveryIsOlderDateThanVaccinations() {
        // GIVEN
        let recoveryCertOlderDateThanVaccinations = recoveryCert
        let dateOfOneOfVaccinations = singleDoseImmunizationJohnsonCert.firstVaccination?.dt
        recoveryCertOlderDateThanVaccinations.vaccinationCertificate.hcert.dgc.r!.first!.fr = dateOfOneOfVaccinations!.addingTimeInterval(-2000)
        let certs = [recoveryCertOlderDateThanVaccinations,
                     singleDoseImmunizationJohnsonCert,
                     doubleDoseImmunizationJohnsonCert,
                     someOtherCert1]
        
        // WHEN
        let candidateForReissue = certs.filterBoosterAfterVaccinationAfterRecoveryFromGermany
        
        // THEN
        XCTAssertTrue(certs.qualifiedForReissue)
        XCTAssertFalse(candidateForReissue.isEmpty)
        XCTAssertEqual(candidateForReissue.count, 3)
        XCTAssertTrue(candidateForReissue.contains(singleDoseImmunizationJohnsonCert))
        XCTAssertTrue(candidateForReissue.contains(doubleDoseImmunizationJohnsonCert))
        XCTAssertTrue(candidateForReissue.contains(recoveryCert))
        XCTAssertFalse(candidateForReissue.contains(someOtherCert1))
        XCTAssertFalse(candidateForReissue.contains(someOtherCert2))
    }
    
    func testBoosterAfterVaccinationAfterRecoveryWithoutRecovery() {
        // GIVEN
        let certs = [someOtherCert2,
                     singleDoseImmunizationJohnsonCert,
                     someOtherCert1,
                     vaccinationWithTwoShotsOfVaccine]
        
        // WHEN
        let candidateForReissue = certs.filterBoosterAfterVaccinationAfterRecoveryFromGermany
        
        // THEN
        XCTAssertTrue(certs.qualifiedForReissue)
        XCTAssertFalse(candidateForReissue.isEmpty)
        XCTAssertTrue(candidateForReissue.count == 2)
        XCTAssertTrue(candidateForReissue.contains(singleDoseImmunizationJohnsonCert))
        XCTAssertTrue(candidateForReissue.contains(vaccinationWithTwoShotsOfVaccine))
        XCTAssertFalse(candidateForReissue.contains(someOtherCert1))
        XCTAssertFalse(candidateForReissue.contains(someOtherCert2))
    }
    
    func testBoosterAfterVaccinationAfterRecoveryWithRecoveryDateOlderThanVaccinationDates() {
        let recoveryCertOlderDateThanVaccinations = recoveryCert
        let dateOfOneOfVaccinations = singleDoseImmunizationJohnsonCert.firstVaccination?.dt
        recoveryCertOlderDateThanVaccinations.vaccinationCertificate.hcert.dgc.r!.first!.fr = dateOfOneOfVaccinations!.addingTimeInterval(-2000)
        // GIVEN
        let certs = [someOtherCert2,
                     recoveryCertOlderDateThanVaccinations,
                     singleDoseImmunizationJohnsonCert,
                     someOtherCert1,
                     vaccinationWithTwoShotsOfVaccine]
        
        // WHEN
        let candidateForReissue = certs.filterBoosterAfterVaccinationAfterRecoveryFromGermany
        
        // THEN
        XCTAssertTrue(certs.qualifiedForReissue)
        XCTAssertFalse(candidateForReissue.isEmpty)
        XCTAssertEqual(candidateForReissue.count, 3)
        XCTAssertTrue(candidateForReissue.contains(singleDoseImmunizationJohnsonCert))
        XCTAssertTrue(candidateForReissue.contains(vaccinationWithTwoShotsOfVaccine))
        XCTAssertTrue(candidateForReissue.contains(recoveryCert))
        XCTAssertFalse(candidateForReissue.contains(someOtherCert1))
        XCTAssertFalse(candidateForReissue.contains(someOtherCert2))
    }
    
    func testBoosterAfterVaccinationAfterRecoveryWithRecoveryDateOlderThanVaccinationDatesWithOneCertIsNotDEIssuer() {
        let recoveryCertOlderDateThanVaccinations = recoveryCert
        let dateOfOneOfVaccinations = singleDoseImmunizationJohnsonCert.firstVaccination?.dt
        recoveryCertOlderDateThanVaccinations.vaccinationCertificate.hcert.dgc.r!.first!.fr = dateOfOneOfVaccinations!.addingTimeInterval(-2000)
        var singleDoseImmunizationJohnsonCert = singleDoseImmunizationJohnsonCert
        singleDoseImmunizationJohnsonCert.vaccinationCertificate.iss = "EN"
        // GIVEN
        let certs = [someOtherCert2,
                     recoveryCertOlderDateThanVaccinations,
                     singleDoseImmunizationJohnsonCert,
                     someOtherCert1,
                     vaccinationWithTwoShotsOfVaccine]
        
        // WHEN
        let candidateForReissue = certs.filterBoosterAfterVaccinationAfterRecoveryFromGermany
        
        // THEN
        XCTAssertFalse(certs.qualifiedForReissue)
        XCTAssertTrue(candidateForReissue.isEmpty)
        XCTAssertEqual(candidateForReissue.count, 0)
        XCTAssertFalse(candidateForReissue.contains(singleDoseImmunizationJohnsonCert))
        XCTAssertFalse(candidateForReissue.contains(vaccinationWithTwoShotsOfVaccine))
        XCTAssertFalse(candidateForReissue.contains(recoveryCert))
        XCTAssertFalse(candidateForReissue.contains(someOtherCert1))
        XCTAssertFalse(candidateForReissue.contains(someOtherCert2))
    }
    
    func testBoosterAfterVaccinationAfterRecoveryWithRecoveryDateFresherThanVaccinationDates() {
        // GIVEN
        let certs = [someOtherCert2,
                     recoveryCert2,
                     singleDoseImmunizationJohnsonCert,
                     someOtherCert1,
                     vaccinationWithTwoShotsOfVaccine,
                     recoveryCert]
        
        // WHEN
        let candidateForReissue = certs.filterBoosterAfterVaccinationAfterRecoveryFromGermany
        
        // THEN
        XCTAssertTrue(certs.qualifiedForReissue)
        XCTAssertFalse(candidateForReissue.isEmpty)
        XCTAssertEqual(candidateForReissue.count, 2)
        XCTAssertTrue(candidateForReissue.contains(singleDoseImmunizationJohnsonCert))
        XCTAssertTrue(candidateForReissue.contains(vaccinationWithTwoShotsOfVaccine))
        XCTAssertFalse(candidateForReissue.contains(recoveryCert))
        XCTAssertFalse(candidateForReissue.contains(someOtherCert1))
        XCTAssertFalse(candidateForReissue.contains(someOtherCert2))
    }
    
    func testIsNotReIssueCandidate() {
        // GIVEN
        let certs = [someOtherCert2,
                     recoveryCert2,
                     someOtherCert1,
                     vaccinationWithTwoShotsOfVaccine,
                     recoveryCert]
        
        // WHEN
        let candidateForReissue = certs.qualifiedForReissue
        
        // THEN
        XCTAssertFalse(candidateForReissue)
    }
    
    func testIsNotReIssueCandidate2() {
        // GIVEN
        let certs = [someOtherCert2,
                     someOtherCert1]
        
        // WHEN
        let candidateForReissue = certs.qualifiedForReissue
        
        // THEN
        XCTAssertFalse(candidateForReissue)
    }
    
    func testIsNotReIssueCandidate3() {
        // GIVEN
        let certs = [recoveryCert,
                     singleDoseImmunizationJohnsonCert]
        
        // WHEN
        let candidateForReissue = certs.qualifiedForReissue
        
        // THEN
        XCTAssertFalse(candidateForReissue)
    }
    
    func testIsNotReIssueCandidateBecauseReIssueAlmostDone() {
        // GIVEN
        var certs = [someOtherCert2,
                     singleDoseImmunizationJohnsonCert,
                     someOtherCert1,
                     vaccinationWithTwoShotsOfVaccine]
        
        // WHEN
        let candidateForReissue = certs.qualifiedForReissue
        
        // THEN
        XCTAssertTrue(candidateForReissue)
        
        // BUT WHEN
        certs.append(boosterCertificateAfterReIssue)
        let candidateForReissueAfterReissue = certs.qualifiedForReissue
        
        // THEN
        XCTAssertFalse(candidateForReissueAfterReissue)
    }
    
    func testAlreadySeen_Default() {
        // GIVEN
        let certs = [someOtherCert2,
                     singleDoseImmunizationJohnsonCert,
                     someOtherCert1,
                     vaccinationWithTwoShotsOfVaccine]
        
        // WHEN
        let reissueNewBadgeAlreadySeen = certs.reissueNewBadgeAlreadySeen
        
        // THEN
        XCTAssertNil(someOtherCert2.reissueProcessNewBadgeAlreadySeen)
        XCTAssertNil(singleDoseImmunizationJohnsonCert.reissueProcessNewBadgeAlreadySeen)
        XCTAssertNil(someOtherCert1.reissueProcessNewBadgeAlreadySeen)
        XCTAssertNil(vaccinationWithTwoShotsOfVaccine.reissueProcessNewBadgeAlreadySeen)
        XCTAssertFalse(reissueNewBadgeAlreadySeen)
    }
    
    func testAlreadySeen_OneCertAlreadySeen() {
        // GIVEN
        someOtherCert2.reissueProcessNewBadgeAlreadySeen = true
        let certs = [someOtherCert2,
                     singleDoseImmunizationJohnsonCert,
                     someOtherCert1,
                     vaccinationWithTwoShotsOfVaccine]
        
        // WHEN
        let reissueNewBadgeAlreadySeen = certs.reissueNewBadgeAlreadySeen
        
        // THEN
        XCTAssertNotNil(someOtherCert2.reissueProcessNewBadgeAlreadySeen)
        XCTAssertNil(singleDoseImmunizationJohnsonCert.reissueProcessNewBadgeAlreadySeen)
        XCTAssertNil(someOtherCert1.reissueProcessNewBadgeAlreadySeen)
        XCTAssertNil(vaccinationWithTwoShotsOfVaccine.reissueProcessNewBadgeAlreadySeen)
        XCTAssertTrue(reissueNewBadgeAlreadySeen)
    }
    
    func testAlreadySeen_AllCertAlreadySeen() {
        // GIVEN
        someOtherCert2.reissueProcessNewBadgeAlreadySeen = true
        singleDoseImmunizationJohnsonCert.reissueProcessNewBadgeAlreadySeen = true
        someOtherCert1.reissueProcessNewBadgeAlreadySeen = true
        vaccinationWithTwoShotsOfVaccine.reissueProcessNewBadgeAlreadySeen = true
        let certs = [someOtherCert2,
                     singleDoseImmunizationJohnsonCert,
                     someOtherCert1,
                     vaccinationWithTwoShotsOfVaccine]
        
        // WHEN
        let reissueNewBadgeAlreadySeen = certs.reissueNewBadgeAlreadySeen
        
        // THEN
        XCTAssertNotNil(someOtherCert2.reissueProcessNewBadgeAlreadySeen)
        XCTAssertNotNil(singleDoseImmunizationJohnsonCert.reissueProcessNewBadgeAlreadySeen)
        XCTAssertNotNil(someOtherCert1.reissueProcessNewBadgeAlreadySeen)
        XCTAssertNotNil(vaccinationWithTwoShotsOfVaccine.reissueProcessNewBadgeAlreadySeen)
        XCTAssertTrue(reissueNewBadgeAlreadySeen)
    }
    
    func testAlreadySeen_NoOfCertsAlreadySeen() {
        // GIVEN
        someOtherCert2.reissueProcessNewBadgeAlreadySeen = false
        singleDoseImmunizationJohnsonCert.reissueProcessNewBadgeAlreadySeen = false
        someOtherCert1.reissueProcessNewBadgeAlreadySeen = false
        vaccinationWithTwoShotsOfVaccine.reissueProcessNewBadgeAlreadySeen = false
        let certs = [someOtherCert2,
                     singleDoseImmunizationJohnsonCert,
                     someOtherCert1,
                     vaccinationWithTwoShotsOfVaccine]
        
        // WHEN
        let reissueNewBadgeAlreadySeen = certs.reissueNewBadgeAlreadySeen
        
        // THEN
        XCTAssertNotNil(someOtherCert2.reissueProcessNewBadgeAlreadySeen)
        XCTAssertNotNil(singleDoseImmunizationJohnsonCert.reissueProcessNewBadgeAlreadySeen)
        XCTAssertNotNil(someOtherCert1.reissueProcessNewBadgeAlreadySeen)
        XCTAssertNotNil(vaccinationWithTwoShotsOfVaccine.reissueProcessNewBadgeAlreadySeen)
        XCTAssertFalse(reissueNewBadgeAlreadySeen)
    }
    
    func testAlreadySeen_OneOfCertsAlreadySeenFalse() {
        // GIVEN
        someOtherCert2.reissueProcessNewBadgeAlreadySeen = false
        let certs = [someOtherCert2,
                     singleDoseImmunizationJohnsonCert,
                     someOtherCert1,
                     vaccinationWithTwoShotsOfVaccine]
        
        // WHEN
        let reissueNewBadgeAlreadySeen = certs.reissueNewBadgeAlreadySeen
        
        // THEN
        XCTAssertNotNil(someOtherCert2.reissueProcessNewBadgeAlreadySeen)
        XCTAssertNil(singleDoseImmunizationJohnsonCert.reissueProcessNewBadgeAlreadySeen)
        XCTAssertNil(someOtherCert1.reissueProcessNewBadgeAlreadySeen)
        XCTAssertNil(vaccinationWithTwoShotsOfVaccine.reissueProcessNewBadgeAlreadySeen)
        XCTAssertFalse(reissueNewBadgeAlreadySeen)
    }
    
    func testReissueProcessInitialAlreadySeen_Default() {
        // GIVEN
        let certs = [someOtherCert2,
                     singleDoseImmunizationJohnsonCert,
                     someOtherCert1,
                     vaccinationWithTwoShotsOfVaccine]
        
        // WHEN
        let reissueProcessInitialAlreadySeen = certs.reissueProcessInitialAlreadySeen
        let reissueProcessInitialNotAlreadySeen = certs.reissueProcessInitialNotAlreadySeen
        
        // THEN
        XCTAssertNil(someOtherCert2.reissueProcessInitialAlreadySeen)
        XCTAssertNil(singleDoseImmunizationJohnsonCert.reissueProcessInitialAlreadySeen)
        XCTAssertNil(someOtherCert1.reissueProcessInitialAlreadySeen)
        XCTAssertNil(vaccinationWithTwoShotsOfVaccine.reissueProcessInitialAlreadySeen)
        XCTAssertFalse(reissueProcessInitialAlreadySeen)
        XCTAssertTrue(reissueProcessInitialNotAlreadySeen)
    }
    
    func testReissueProcessInitialAlreadySeen_OneCertAlreadySeen() {
        // GIVEN
        someOtherCert2.reissueProcessInitialAlreadySeen = true
        let certs = [someOtherCert2,
                     singleDoseImmunizationJohnsonCert,
                     someOtherCert1,
                     vaccinationWithTwoShotsOfVaccine]
        
        // WHEN
        let reissueProcessInitialAlreadySeen = certs.reissueProcessInitialAlreadySeen
        let reissueProcessInitialNotAlreadySeen = certs.reissueProcessInitialNotAlreadySeen
        
        // THEN
        XCTAssertNotNil(someOtherCert2.reissueProcessInitialAlreadySeen)
        XCTAssertNil(singleDoseImmunizationJohnsonCert.reissueProcessInitialAlreadySeen)
        XCTAssertNil(someOtherCert1.reissueProcessInitialAlreadySeen)
        XCTAssertNil(vaccinationWithTwoShotsOfVaccine.reissueProcessInitialAlreadySeen)
        XCTAssertTrue(reissueProcessInitialAlreadySeen)
        XCTAssertFalse(reissueProcessInitialNotAlreadySeen)
    }
    
    func testReissueProcessInitialAlreadySeen_AllCertAlreadySeen() {
        // GIVEN
        someOtherCert2.reissueProcessInitialAlreadySeen = true
        singleDoseImmunizationJohnsonCert.reissueProcessInitialAlreadySeen = true
        someOtherCert1.reissueProcessInitialAlreadySeen = true
        vaccinationWithTwoShotsOfVaccine.reissueProcessInitialAlreadySeen = true
        let certs = [someOtherCert2,
                     singleDoseImmunizationJohnsonCert,
                     someOtherCert1,
                     vaccinationWithTwoShotsOfVaccine]
        
        // WHEN
        let reissueProcessInitialAlreadySeen = certs.reissueProcessInitialAlreadySeen
        let reissueProcessInitialNotAlreadySeen = certs.reissueProcessInitialNotAlreadySeen
        
        // THEN
        XCTAssertNotNil(someOtherCert2.reissueProcessInitialAlreadySeen)
        XCTAssertNotNil(singleDoseImmunizationJohnsonCert.reissueProcessInitialAlreadySeen)
        XCTAssertNotNil(someOtherCert1.reissueProcessInitialAlreadySeen)
        XCTAssertNotNil(vaccinationWithTwoShotsOfVaccine.reissueProcessInitialAlreadySeen)
        XCTAssertTrue(reissueProcessInitialAlreadySeen)
        XCTAssertFalse(reissueProcessInitialNotAlreadySeen)
    }
    
    func testReissueProcessInitialAlreadySeen_NoOfCertsAlreadySeen() {
        // GIVEN
        someOtherCert2.reissueProcessInitialAlreadySeen = false
        singleDoseImmunizationJohnsonCert.reissueProcessInitialAlreadySeen = false
        someOtherCert1.reissueProcessInitialAlreadySeen = false
        vaccinationWithTwoShotsOfVaccine.reissueProcessInitialAlreadySeen = false
        let certs = [someOtherCert2,
                     singleDoseImmunizationJohnsonCert,
                     someOtherCert1,
                     vaccinationWithTwoShotsOfVaccine]
        
        // WHEN
        let reissueProcessInitialAlreadySeen = certs.reissueProcessInitialAlreadySeen
        let reissueProcessInitialNotAlreadySeen = certs.reissueProcessInitialNotAlreadySeen
        
        // THEN
        XCTAssertNotNil(someOtherCert2.reissueProcessInitialAlreadySeen)
        XCTAssertNotNil(singleDoseImmunizationJohnsonCert.reissueProcessInitialAlreadySeen)
        XCTAssertNotNil(someOtherCert1.reissueProcessInitialAlreadySeen)
        XCTAssertNotNil(vaccinationWithTwoShotsOfVaccine.reissueProcessInitialAlreadySeen)
        XCTAssertFalse(reissueProcessInitialAlreadySeen)
        XCTAssertTrue(reissueProcessInitialNotAlreadySeen)
    }
    
    func testReissueProcessInitialAlreadySeen_OneOfCertsAlreadySeenFalse() {
        // GIVEN
        someOtherCert2.reissueProcessInitialAlreadySeen = false
        let certs = [someOtherCert2,
                     singleDoseImmunizationJohnsonCert,
                     someOtherCert1,
                     vaccinationWithTwoShotsOfVaccine]
        
        // WHEN
        let reissueProcessInitialAlreadySeen = certs.reissueProcessInitialAlreadySeen
        let reissueProcessInitialNotAlreadySeen = certs.reissueProcessInitialNotAlreadySeen
        
        // THEN
        XCTAssertNotNil(someOtherCert2.reissueProcessInitialAlreadySeen)
        XCTAssertNil(singleDoseImmunizationJohnsonCert.reissueProcessInitialAlreadySeen)
        XCTAssertNil(someOtherCert1.reissueProcessInitialAlreadySeen)
        XCTAssertNil(vaccinationWithTwoShotsOfVaccine.reissueProcessInitialAlreadySeen)
        XCTAssertFalse(reissueProcessInitialAlreadySeen)
        XCTAssertTrue(reissueProcessInitialNotAlreadySeen)
    }
    
    func testFilterCertificatesSamePerson() {
        // GIVEN
        let certOfJohnDoe = boosterCertificateAfterReIssue
        let certOfEllaKatami = CBORWebToken.mockVaccinationCertificateWithOtherName.extended()
        let certsOfJohnAndOneOfElla = [someOtherCert2,
                                       singleDoseImmunizationJohnsonCert,
                                       someOtherCert1,
                                       vaccinationWithTwoShotsOfVaccine,
                                       recoveryCert,
                                       recoveryCert2,
                                       certOfEllaKatami]
        
        // WHEN
        let filteredCertsForJohn = certsOfJohnAndOneOfElla.filterMatching(certOfJohnDoe)
        
        // THEN
        XCTAssertEqual(filteredCertsForJohn.count, 6)
        XCTAssertTrue(filteredCertsForJohn.contains(someOtherCert2))
        XCTAssertTrue(filteredCertsForJohn.contains(singleDoseImmunizationJohnsonCert))
        XCTAssertTrue(filteredCertsForJohn.contains(someOtherCert1))
        XCTAssertTrue(filteredCertsForJohn.contains(vaccinationWithTwoShotsOfVaccine))
        XCTAssertTrue(filteredCertsForJohn.contains(recoveryCert))
        XCTAssertTrue(filteredCertsForJohn.contains(recoveryCert2))
        XCTAssertFalse(filteredCertsForJohn.contains(certOfEllaKatami))
    }
    
    func testFilterCertificatesSamePersonAlternative() {
        // GIVEN
        let certOfEllaKatami = CBORWebToken.mockVaccinationCertificateWithOtherName.extended()
        let certsOfJohnAndOneOfElla = [someOtherCert2,
                                       singleDoseImmunizationJohnsonCert,
                                       someOtherCert1,
                                       vaccinationWithTwoShotsOfVaccine,
                                       recoveryCert,
                                       recoveryCert2,
                                       certOfEllaKatami]
        
        // WHEN
        let filteredCertsForElla = certsOfJohnAndOneOfElla.filterMatching(certOfEllaKatami)
        
        // THEN
        XCTAssertEqual(filteredCertsForElla.count, 1)
        XCTAssertFalse(filteredCertsForElla.contains(someOtherCert2))
        XCTAssertFalse(filteredCertsForElla.contains(singleDoseImmunizationJohnsonCert))
        XCTAssertFalse(filteredCertsForElla.contains(someOtherCert1))
        XCTAssertFalse(filteredCertsForElla.contains(vaccinationWithTwoShotsOfVaccine))
        XCTAssertFalse(filteredCertsForElla.contains(recoveryCert))
        XCTAssertFalse(filteredCertsForElla.contains(recoveryCert2))
        XCTAssertTrue(filteredCertsForElla.contains(certOfEllaKatami))
    }
    
    func testSortedByDnVacinationRecoveryAndTestCertficateMixed() {
        // GIVEN
        var certs = [singleDoseImmunizationJohnsonCert,
                     recoveryCert,
                     recoveryCert2,
                     vaccinationWithTwoShotsOfVaccine]
        
        // WHEN
        certs = certs.sortedByDn
        
        // THEN
        XCTAssertEqual(certs[0], vaccinationWithTwoShotsOfVaccine)
        XCTAssertEqual(certs[1], singleDoseImmunizationJohnsonCert)
        XCTAssertEqual(certs[2], recoveryCert)
        XCTAssertEqual(certs[3], recoveryCert2)
    }
    
    func testFilter2of1s() {
        // GIVEN
        var certs = [singleDoseImmunizationJohnsonCert,
                     recoveryCert,
                     recoveryCert2,
                     boosterCertificateAfterReIssue,
                     vaccinationWithTwoShotsOfVaccine,
                     doubleDoseImmunizationJohnsonCert]
        
        // WHEN
        certs = certs.filter2Of1
        
        // THEN
        XCTAssertEqual(certs.count, 1)
        XCTAssertEqual(certs[0], boosterCertificateAfterReIssue)
    }
    
    func testFilterRecoveries() {
        // GIVEN
        let certs = [singleDoseImmunizationJohnsonCert,
                     recoveryCert,
                     recoveryCert2,
                     boosterCertificateAfterReIssue,
                     vaccinationWithTwoShotsOfVaccine,
                     doubleDoseImmunizationJohnsonCert]
        
        // WHEN
        let certsOfRecoveries = certs.filterRecoveries
        let recoveries = certs.recoveries

        // THEN
        XCTAssertEqual(certsOfRecoveries.count, 2)
        XCTAssertEqual(certsOfRecoveries[0], recoveryCert)
        XCTAssertEqual(certsOfRecoveries[1], recoveryCert2)
        XCTAssertEqual(recoveries.count, 2)
    }

    func testQualifiedCertificatesForVaccinationExpiryReissue_no_vaccination() {
        // Given
        var recoveryToken = CBORWebToken.mockRecoveryCertificate
        var testToken = CBORWebToken.mockTestCertificate
        recoveryToken.exp = .init(timeIntervalSinceNow: -60)
        testToken.exp = .init(timeIntervalSinceNow: -60)
        let sut: [ExtendedCBORWebToken] = [
            recoveryToken.extended(),
            testToken.extended()
        ]

        // When
        let tokens = sut.qualifiedCertificatesForVaccinationExpiryReissue

        // Then
        XCTAssertTrue(tokens.isEmpty)
    }
    
    func testQualifiedCertificatesForVaccinationExpiryReissue_token_is_reissueable() {
        // Given
        var cborWebToken = CBORWebToken.mockVaccinationCertificate
        cborWebToken.exp = .init(timeIntervalSinceNow: -60)
        let token = cborWebToken.extended(vaccinationQRCodeData: "1")
        var cborWebToken2 = CBORWebToken.mockVaccinationCertificate
        cborWebToken2.exp = .init(timeIntervalSinceNow: -70)
        let token2 = cborWebToken2.extended(vaccinationQRCodeData: "2")
        token2.vaccinationCertificate.hcert.dgc.v!.first!.dt = try! XCTUnwrap(DateUtils.isoDateFormatter.date(from: "2008-01-01"))
        let sut: [ExtendedCBORWebToken] = [
            token,
            token,
            token,
            token,
            token2,
            token,
            token,
            token
        ]

        // When
        let tokens = sut.qualifiedCertificatesForVaccinationExpiryReissue

        // Then
        XCTAssertEqual(tokens.count, 6)
        XCTAssertEqual(tokens.first, token)
    }
    
    func test_expired_have_least_priority() {
        // Given
        var cborWebToken = CBORWebToken.mockVaccinationCertificate
        cborWebToken.exp = .init(timeIntervalSinceNow: -60)
        let tokenExpired = cborWebToken.extended(vaccinationQRCodeData: "1")
        let cborWebToken2 = CBORWebToken.mockVaccinationCertificate
        let tokenNotExpired = cborWebToken2.extended(vaccinationQRCodeData: "2")
        let sut: [ExtendedCBORWebToken] = [tokenExpired,tokenNotExpired]
        
        // WHEN
        let tokens = sut.sortLatest()

        // Then
        XCTAssertEqual(tokens.count, 2)
        XCTAssertEqual(tokens.first, tokenNotExpired)
        XCTAssertEqual(tokens.last, tokenExpired)
    }
    
    func test_revoked_have_least_priority() {
        // Given
        let cborWebToken = CBORWebToken.mockVaccinationCertificate
        var tokenRevoked = cborWebToken.extended(vaccinationQRCodeData: "1")
        tokenRevoked.revoked = true
        let cborWebToken2 = CBORWebToken.mockVaccinationCertificate
        let tokenNotRevoked = cborWebToken2.extended(vaccinationQRCodeData: "2")
        let sut: [ExtendedCBORWebToken] = [tokenRevoked, tokenNotRevoked]
        
        // WHEN
        let tokens = sut.sortLatest()

        // Then
        XCTAssertEqual(tokens.count, 2)
        XCTAssertEqual(tokens.first, tokenNotRevoked)
        XCTAssertEqual(tokens.last, tokenRevoked)
    }
    
    func test_invalid_have_least_priority() {
        // Given
        let cborWebToken = CBORWebToken.mockVaccinationCertificate
        var tokenInvalid = cborWebToken.extended(vaccinationQRCodeData: "1")
        tokenInvalid.invalid = true
        let cborWebToken2 = CBORWebToken.mockVaccinationCertificate
        let tokenNotInvalid = cborWebToken2.extended(vaccinationQRCodeData: "2")
        let sut: [ExtendedCBORWebToken] = [tokenInvalid, tokenNotInvalid]
        
        // WHEN
        let tokens = sut.sortLatest()

        // Then
        XCTAssertEqual(tokens.count, 2)
        XCTAssertEqual(tokens.first, tokenNotInvalid)
        XCTAssertEqual(tokens.last, tokenInvalid)
    }
    
    func test_all_invalids_have_least_priority_but_sorted_by_dtScFr() {
        // Given
        let vaccinationIdentifier = "vaccination"
        let testIdentifier = "test"
        let recoveryIdentifier = "recovery"
        let vaccinationDate = try! XCTUnwrap(DateUtils.isoDateFormatter.date(from: "2022-02-04"))
        let testDate = try! XCTUnwrap(DateUtils.isoDateFormatter.date(from: "2022-02-05"))
        let recoveryDate = try! XCTUnwrap(DateUtils.isoDateFormatter.date(from: "2022-02-03"))
        var tokenVaccination = CBORWebToken.mockVaccinationCertificate
            .mockVaccinationSetDate(vaccinationDate)
            .extended(vaccinationQRCodeData: vaccinationIdentifier)
        var tokenTest = CBORWebToken.mockTestCertificate
            .mockTestSetDate(testDate)
            .extended(vaccinationQRCodeData: testIdentifier)
        var tokenRecovery = CBORWebToken.mockRecoveryCertificate
            .mockRecoverySetDate(recoveryDate)
            .extended(vaccinationQRCodeData: recoveryIdentifier)
        
        tokenVaccination.revoked = true
        tokenTest.vaccinationCertificate.exp = .init(timeIntervalSinceNow: -60)
        tokenRecovery.invalid = true

        let sut: [ExtendedCBORWebToken] = [tokenVaccination, tokenTest, tokenRecovery]
        
        // WHEN
        let tokens = sut.sortLatest()

        // Then
        XCTAssertEqual(tokens.count, 3)
        XCTAssertEqual(tokens[0].vaccinationQRCodeData, testIdentifier)
        XCTAssertEqual(tokens[1].vaccinationQRCodeData, vaccinationIdentifier)
        XCTAssertEqual(tokens[2].vaccinationQRCodeData, recoveryIdentifier)
    }
    
    func testQualifiedCertificatesForVaccinationExpiryReissue_token_is_not_reissueable() {
        // Given
        var cborWebToken = CBORWebToken.mockVaccinationCertificate
        cborWebToken.exp = .init(timeIntervalSinceNow: -60)
        let token = cborWebToken.extended(vaccinationQRCodeData: "1")
        let sut: [ExtendedCBORWebToken] = [
            token,
            token,
            token,
            token,
            CBORWebToken.mockVaccinationCertificate.extended(vaccinationQRCodeData: "2"),
            token,
            token,
            token
        ]

        // When
        let tokens = sut.qualifiedCertificatesForVaccinationExpiryReissue

        // Then
        XCTAssertEqual(tokens.count, 0)
        XCTAssertNil(tokens.first)
    }

    func testQualifiedCertificatesForVaccinationExpiryReissue_older_recovery_included() {
        // Given
        let now = Date()

        var vaccinationCborWebToken = CBORWebToken.mockVaccinationCertificate.mockVaccinationSetDate(now-3)
        vaccinationCborWebToken.exp = now - 1
        let vaccinationToken = vaccinationCborWebToken.extended(vaccinationQRCodeData: "vaccinationToken")

        var recoveryCborWebToken = CBORWebToken.mockRecoveryCertificate.mockRecovery(fr: now-4)
        recoveryCborWebToken.exp = now - 2
        let recoveryToken = recoveryCborWebToken.extended(vaccinationQRCodeData: "recoveryToken")

        let sut: [ExtendedCBORWebToken] = [
            vaccinationToken,
            recoveryToken
        ]

        // When
        let tokens = sut.qualifiedCertificatesForVaccinationExpiryReissue

        // Then
        if tokens.count == 2 {
            XCTAssertEqual(tokens[0], vaccinationToken)
            XCTAssertEqual(tokens[1], recoveryToken)
        } else {
            XCTFail("Count is wrong: \(tokens.count)")
        }
    }

    func testQualifiedCertificatesForVaccinationExpiryReissue_newer_recovery_not_included() {
        // Given
        let now = Date()

        var vaccinationCborWebToken = CBORWebToken.mockVaccinationCertificate
            .mockVaccinationSetDate(now-2)
        vaccinationCborWebToken.exp = now
        let vaccinationToken = vaccinationCborWebToken.extended(vaccinationQRCodeData: "vaccinationToken")

        var recoveryCborWebToken = CBORWebToken.mockRecoveryCertificate
            .mockRecovery(fr: now-1)
        recoveryCborWebToken.exp = now
        let recoveryToken = recoveryCborWebToken.extended(vaccinationQRCodeData: "recoveryToken")

        let sut: [ExtendedCBORWebToken] = [
            vaccinationToken,
            recoveryToken
        ]

        // When
        let tokens = sut.qualifiedCertificatesForVaccinationExpiryReissue

        // Then
        if tokens.count == 1 {
            XCTAssertTrue(tokens.contains(vaccinationToken))
        } else {
            XCTFail("Count is wrong.")
        }
    }

    func testQualifiedCertificatesForVaccinationExpiryReissue_older_non_tests_included() {
        // Given
        let now = Date()

        var vaccinationCborWebToken = CBORWebToken.mockVaccinationCertificate
            .mockVaccinationSetDate(now)
        vaccinationCborWebToken.exp = now
        let vaccinationToken = vaccinationCborWebToken.extended(vaccinationQRCodeData: "vaccinationToken")

        var cborToken1 = CBORWebToken.mockRecoveryCertificate.mockRecovery(fr: now-2)
        cborToken1.exp = now-2
        var token1 = cborToken1.extended(vaccinationQRCodeData: "token1")
        token1.revoked = true

        var cborToken2 = CBORWebToken.mockRecoveryCertificate.mockRecovery(fr: now-3)
        cborToken2.exp = now-3
        var token2 = cborToken2.extended(vaccinationQRCodeData: "token2")
        token2.invalid = true

        var cborToken3 = CBORWebToken.mockTestCertificate
            .mockVaccinationSetDate(now-4)
        cborToken3.exp = now-4
        let token3 = cborToken3.extended(vaccinationQRCodeData: "token3")

        var cborToken4 = CBORWebToken.mockVaccinationCertificate.mockVaccinationSetDate(now-5)
        cborToken4.exp = now-5
        let token4 = cborToken4.extended(vaccinationQRCodeData: "token4")

        let sut: [ExtendedCBORWebToken] = [
            vaccinationToken,
            token4,
            token3,
            token2,
            token1
        ]

        // When
        let tokens = sut.qualifiedCertificatesForVaccinationExpiryReissue

        // Then
        if tokens.count == 4 {
            XCTAssertEqual(tokens[0], vaccinationToken)
            XCTAssertEqual(tokens[1], token1)
            XCTAssertEqual(tokens[2], token2)
            XCTAssertEqual(tokens[3], token4)
        } else {
            XCTFail("Count is wrong.")
        }
    }

    func testQualifiedCertificatesForVaccinationExpiryReissue_token_is_not_german() {
        // Given
        var cborWebToken = CBORWebToken.mockVaccinationCertificate
        cborWebToken.exp = .init(timeIntervalSinceNow: -60)
        cborWebToken.iss = "PL"
        let token = cborWebToken.extended()
        let sut: [ExtendedCBORWebToken] = [
            token
        ]

        // When
        let tokens = sut.qualifiedCertificatesForVaccinationExpiryReissue

        // Then
        XCTAssertTrue(tokens.isEmpty)
    }

    func testQualifiedCertificatesForVaccinationExpiryReissue_token_to_old() {
        // Given
        var cborWebToken = CBORWebToken.mockVaccinationCertificate
        cborWebToken.exp = .init(timeIntervalSinceReferenceDate: 0)
        let token = cborWebToken.extended()
        let sut: [ExtendedCBORWebToken] = [
            token
        ]

        // When
        let tokens = sut.qualifiedCertificatesForVaccinationExpiryReissue

        // Then
        XCTAssertTrue(tokens.isEmpty)
    }

    func testQualifiedCertificatesForVaccinationExpiryReissue_vaccination_is_revoked() {
        // Given
        var cborWebToken = CBORWebToken.mockVaccinationCertificate
        cborWebToken.exp = .init(timeIntervalSinceNow: -60)
        var token = cborWebToken.extended(vaccinationQRCodeData: "1")
        token.revoked = true
        let sut: [ExtendedCBORWebToken] = [
            token
        ]

        // When
        let tokens = sut.qualifiedCertificatesForVaccinationExpiryReissue

        // Then
        XCTAssertTrue(tokens.isEmpty)
    }

    func testAreVaccinationsQualifiedForExpiryReissue_no_vaccination() {
        // Given
        var cborWebToken = CBORWebToken.mockRecoveryCertificate
        cborWebToken.exp = .init(timeIntervalSinceNow: -60)
        let token = cborWebToken.extended(vaccinationQRCodeData: "1")
        let sut: [ExtendedCBORWebToken] = [
            token,
            CBORWebToken.mockTestCertificate.extended()
        ]

        // When
        let areVaccinationsQualifiedForExpiryReissue = sut.areVaccinationsQualifiedForExpiryReissue

        // Then
        XCTAssertFalse(areVaccinationsQualifiedForExpiryReissue)
    }

    func testAreVaccinationsQualifiedForExpiryReissue_token_is_reissueable() {
        // Given
        var cborWebToken = CBORWebToken.mockVaccinationCertificate
        cborWebToken.exp = .init(timeIntervalSinceNow: -60)
        let token = cborWebToken.extended()
        let sut: [ExtendedCBORWebToken] = [
            token
        ]

        // When
        let areVaccinationsQualifiedForExpiryReissue = sut.areVaccinationsQualifiedForExpiryReissue

        // Then
        XCTAssertTrue(areVaccinationsQualifiedForExpiryReissue)
    }

    // MARK: -

    func testQualifiedCertificatesForRecoveryExpiryReissue_no_vaccination() {
        // Given
        var vaccinationToken = CBORWebToken.mockVaccinationCertificate
        var testToken = CBORWebToken.mockTestCertificate
        vaccinationToken.exp = .init(timeIntervalSinceNow: -60)
        testToken.exp = .init(timeIntervalSinceNow: -60)
        let sut: [ExtendedCBORWebToken] = [
            vaccinationToken.extended(),
            testToken.extended()
        ]

        // When
        let tokens = sut.qualifiedCertificatesForRecoveryExpiryReissue

        // Then
        XCTAssertTrue(tokens.isEmpty)
    }

    func testQualifiedCertificatesForRecoveryExpiryReissue_token_is_reissueable() throws {
        // Given
        var cborWebToken = CBORWebToken.mockRecoveryCertificate
        cborWebToken.exp = .init(timeIntervalSinceNow: -60)
        let token = cborWebToken.extended(vaccinationQRCodeData: "1")
        let sut: [ExtendedCBORWebToken] = [
            token,
            token,
            token,
            token,
            CBORWebToken.mockVaccinationCertificate.extended(),
            token,
            token,
            token
        ]

        // When
        let tokens = try XCTUnwrap(
            sut.qualifiedCertificatesForRecoveryExpiryReissue.first
        )

        // Then
        XCTAssertEqual(tokens.count, 6)
        XCTAssertEqual(tokens.first, token)
    }

    func testQualifiedCertificatesForRecoveryExpiryReissue_older_vaccination_included() throws {
        // Given
        let now = Date()

        var recoveryCborWebToken = CBORWebToken.mockRecoveryCertificate.mockRecovery(fr: now)
        recoveryCborWebToken.exp = now - 2
        let recoveryToken = recoveryCborWebToken.extended(vaccinationQRCodeData: "recoveryToken")

        var vaccinationCborWebToken = CBORWebToken.mockVaccinationCertificate.mockVaccinationSetDate(now-1)
        vaccinationCborWebToken.exp = now - 1
        let vaccinationToken = vaccinationCborWebToken.extended(vaccinationQRCodeData: "vaccinationToken")

        let sut: [ExtendedCBORWebToken] = [
            vaccinationToken,
            recoveryToken
        ]

        // When
        let tokens = try XCTUnwrap(
            sut.qualifiedCertificatesForRecoveryExpiryReissue.first
        )

        // Then
        if tokens.count == 2 {
            XCTAssertEqual(tokens[0], recoveryToken)
            XCTAssertEqual(tokens[1], vaccinationToken)
        } else {
            XCTFail("Count is wrong: \(tokens.count)")
        }
    }

    func testQualifiedCertificatesForRecoveryExpiryReissue_newer_vaccination_not_included() throws {
        // Given
        let now = Date()

        var recoveryCborWebToken = CBORWebToken.mockRecoveryCertificate
            .mockRecovery(fr: now-2)
        recoveryCborWebToken.exp = now
        let recoveryToken = recoveryCborWebToken.extended(vaccinationQRCodeData: "recoveryToken")

        var vaccinationCborWebToken = CBORWebToken.mockVaccinationCertificate
            .mockVaccinationSetDate(now-1)
        vaccinationCborWebToken.exp = now
        let vaccinationToken = vaccinationCborWebToken.extended(vaccinationQRCodeData: "vaccinationToken")

        let sut: [ExtendedCBORWebToken] = [
            vaccinationToken,
            recoveryToken
        ]

        // When
        let tokens = try XCTUnwrap(
            sut.qualifiedCertificatesForRecoveryExpiryReissue.first
        )

        // Then
        if tokens.count == 1 {
            XCTAssertTrue(tokens.contains(recoveryToken))
        } else {
            XCTFail("Count is wrong.")
        }
    }

    func testQualifiedCertificatesForRecoveryExpiryReissue_older_non_tests_included() throws {
        // Given
        let now = Date()

        var recoveryCborWebToken = CBORWebToken.mockRecoveryCertificate
            .mockRecovery(fr: now)
        recoveryCborWebToken.exp = now
        let recoveryToken = recoveryCborWebToken.extended(vaccinationQRCodeData: "recoveryToken")

        let cborToken1 = CBORWebToken.mockVaccinationCertificate.mockVaccinationSetDate(now-2)
        var token1 = cborToken1.extended(vaccinationQRCodeData: "token1")
        token1.revoked = true

        let cborToken2 = CBORWebToken.mockRecoveryCertificate.mockRecovery(fr: now-3)
        var token2 = cborToken2.extended(vaccinationQRCodeData: "token2")
        token2.invalid = true

        let cborToken3 = CBORWebToken.mockTestCertificate.mockVaccinationSetDate(now-4)
        let token3 = cborToken3.extended(vaccinationQRCodeData: "token3")

        let cborToken4 = CBORWebToken.mockVaccinationCertificate.mockVaccinationSetDate(now-5)
        let token4 = cborToken4.extended(vaccinationQRCodeData: "token4")

        let sut: [ExtendedCBORWebToken] = [
            recoveryToken,
            token4,
            token3,
            token2,
            token1
        ]

        // When
        let tokens = try XCTUnwrap(
            sut.qualifiedCertificatesForRecoveryExpiryReissue.first
        )

        // Then
        if tokens.count == 4 {
            XCTAssertEqual(tokens[0], recoveryToken)
            XCTAssertEqual(tokens[1], token1)
            XCTAssertEqual(tokens[2], token2)
            XCTAssertEqual(tokens[3], token4)
        } else {
            XCTFail("Count is wrong.")
        }
    }

    func testQualifiedCertificatesForRecoveryExpiryReissue_token_is_not_german() {
        // Given
        var cborWebToken = CBORWebToken.mockRecoveryCertificate
        cborWebToken.exp = .init(timeIntervalSinceNow: -60)
        cborWebToken.iss = "PL"
        let token = cborWebToken.extended()
        let sut: [ExtendedCBORWebToken] = [
            token
        ]

        // When
        let tokens = sut.qualifiedCertificatesForRecoveryExpiryReissue

        // Then
        XCTAssertTrue(tokens.isEmpty)
    }

    func testQualifiedCertificatesForRecoveryExpiryReissue_token_to_old() {
        // Given
        var cborWebToken = CBORWebToken.mockRecoveryCertificate
        cborWebToken.exp = .init(timeIntervalSinceReferenceDate: 0)
        let token = cborWebToken.extended()
        let sut: [ExtendedCBORWebToken] = [
            token
        ]

        // When
        let tokens = sut.qualifiedCertificatesForRecoveryExpiryReissue

        // Then
        XCTAssertTrue(tokens.isEmpty)
    }

    func testQualifiedCertificatesForRecoveryExpiryReissue_is_revoked() {
        // Given
        var cborWebToken = CBORWebToken.mockRecoveryCertificate
        cborWebToken.exp = .init(timeIntervalSinceNow: -60)
        var token = cborWebToken.extended(vaccinationQRCodeData: "1")
        token.revoked = true
        let sut: [ExtendedCBORWebToken] = [
            token
        ]

        // When
        let tokens = sut.qualifiedCertificatesForRecoveryExpiryReissue

        // Then
        XCTAssertTrue(tokens.isEmpty)
    }

    func testQualifiedCertificatesForRecoveryExpiryReissue_multiple_candidates() {
        let now = Date()
        var cborWebToken1 = CBORWebToken.mockRecoveryCertificate
            .mockRecovery(fr: now)
        cborWebToken1.exp = .init(timeIntervalSinceNow: -60)
        let token1 = cborWebToken1.extended(vaccinationQRCodeData: "1")
        var cborWebToken2 = CBORWebToken.mockRecoveryCertificate
            .mockRecovery(fr: now-1)
        cborWebToken2.exp = .init(timeIntervalSinceNow: -60)
        let token2 = cborWebToken2.extended(vaccinationQRCodeData: "2")
        let token3 = CBORWebToken.mockVaccinationCertificate
            .mockVaccinationSetDate(now-2)
            .extended(vaccinationQRCodeData: "3")
        let sut: [ExtendedCBORWebToken] = [
            token2,
            token3,
            token1
        ]

        // When
        let tokens = sut.qualifiedCertificatesForRecoveryExpiryReissue

        // Then
        if tokens.count == 2 {
            let candidates1 = tokens[0]
            let candidates2 = tokens[1]
            if candidates1.count == 3 {
                XCTAssertEqual(candidates1[0], token1)
                XCTAssertEqual(candidates1[1], token2)
                XCTAssertEqual(candidates1[2], token3)
            } else {
                XCTFail("Count must be 3.")
            }
            if candidates2.count == 2 {
                XCTAssertEqual(candidates2[0], token2)
                XCTAssertEqual(candidates2[1], token3)
            } else {
                XCTFail("Count must be 2.")
            }
        } else {
            XCTFail("Count must be 2.")
        }
    }

    func testVaccinationExpiryReissueNewBadgeAlreadySeen_already_seen() {
        var cborWebToken = CBORWebToken.mockVaccinationCertificate
        cborWebToken.exp = .init(timeIntervalSinceNow: -60)
        var token = cborWebToken.extended(vaccinationQRCodeData: "1")
        token.reissueProcessNewBadgeAlreadySeen = true
        let sut: [ExtendedCBORWebToken] = [token]

        // When
        let alreadySeen = sut.vaccinationExpiryReissueNewBadgeAlreadySeen

        // Then
        XCTAssertTrue(alreadySeen)
    }
    
    func testVaccinationExpiryReissueNewBadgeAlreadySeen_not_already_seen() {
        var cborWebToken = CBORWebToken.mockVaccinationCertificate
        cborWebToken.exp = .init(timeIntervalSinceNow: -60)
        let token = cborWebToken.extended(vaccinationQRCodeData: "1")
        let sut: [ExtendedCBORWebToken] = [token]

        // When
        let alreadySeen = sut.vaccinationExpiryReissueNewBadgeAlreadySeen

        // Then
        XCTAssertFalse(alreadySeen)
    }
    
    func testRemoveDuplicates() throws {
        
        // GIVEN about Vaccination -> later should only stay vaccinationToken3 with latest issued at date and vaccinationToken4
        let vaccinationTokenDt = try XCTUnwrap(DateUtils.parseDate("2021-04-26T15:05:00"))
        let vaccinationTokenDt2 = try XCTUnwrap(DateUtils.parseDate("2021-05-26T15:05:00"))
        let vaccinationToken1Iat = try XCTUnwrap(DateUtils.parseDate("2021-04-28T15:05:00"))
        let vaccinationToken2Iat = try XCTUnwrap(DateUtils.parseDate("2021-04-30T15:05:00"))
        let vaccinationToken3Iat = try XCTUnwrap(DateUtils.parseDate("2022-04-30T15:05:00"))

        var vaccinationToken1 = CBORWebToken.mockVaccinationCertificate.extended(vaccinationQRCodeData: "1")
        vaccinationToken1.vaccinationCertificate.iat = vaccinationToken1Iat
        vaccinationToken1.vaccinationCertificate.hcert.dgc.v!.first!.dt = vaccinationTokenDt

        var vaccinationToken2 = CBORWebToken.mockVaccinationCertificate.extended(vaccinationQRCodeData: "2")
        vaccinationToken2.vaccinationCertificate.iat = vaccinationToken2Iat
        vaccinationToken2.vaccinationCertificate.hcert.dgc.v!.first!.dt = vaccinationTokenDt
        
        var vaccinationToken3 = CBORWebToken.mockVaccinationCertificate.extended(vaccinationQRCodeData: "3")
        vaccinationToken3.vaccinationCertificate.iat = vaccinationToken3Iat
        vaccinationToken3.vaccinationCertificate.hcert.dgc.v!.first!.dt = vaccinationTokenDt
        
        var vaccinationToken4 = CBORWebToken.mockVaccinationCertificate.extended(vaccinationQRCodeData: "4")
        vaccinationToken4.vaccinationCertificate.iat = vaccinationToken3Iat
        vaccinationToken4.vaccinationCertificate.hcert.dgc.v!.first!.dt = vaccinationTokenDt2
        
        
        // GIVEN about Recovery -> later should only stay recoveryToken3 with latest issued at date and recoveryToken4
        let recoveryTokenFr = try XCTUnwrap(DateUtils.parseDate("2022-05-01T15:05:00"))
        let recoveryTokenFr2 = try XCTUnwrap(DateUtils.parseDate("2022-05-02T15:05:00"))
        let recoveryToken1Iat = try XCTUnwrap(DateUtils.parseDate("2022-05-02T15:05:00"))
        let recoveryToken2Iat = try XCTUnwrap(DateUtils.parseDate("2022-05-03T15:05:00"))
        let recoveryToken3Iat = try XCTUnwrap(DateUtils.parseDate("2022-05-04T15:05:00"))
        
        var recoveryToken1 = CBORWebToken.mockRecoveryCertificate.extended(vaccinationQRCodeData: "5")
        recoveryToken1.vaccinationCertificate.iat = recoveryToken1Iat
        recoveryToken1.vaccinationCertificate.hcert.dgc.r!.first!.fr = recoveryTokenFr
        
        var recoveryToken2 = CBORWebToken.mockRecoveryCertificate.extended(vaccinationQRCodeData: "6")
        recoveryToken2.vaccinationCertificate.iat = recoveryToken2Iat
        recoveryToken2.vaccinationCertificate.hcert.dgc.r!.first!.fr = recoveryTokenFr
        
        var recoveryToken3 = CBORWebToken.mockRecoveryCertificate.extended(vaccinationQRCodeData: "7")
        recoveryToken3.vaccinationCertificate.iat = recoveryToken3Iat
        recoveryToken3.vaccinationCertificate.hcert.dgc.r!.first!.fr = recoveryTokenFr
        
        var recoveryToken4 = CBORWebToken.mockRecoveryCertificate.extended(vaccinationQRCodeData: "8")
        recoveryToken4.vaccinationCertificate.iat = recoveryToken3Iat
        recoveryToken4.vaccinationCertificate.hcert.dgc.r!.first!.fr = recoveryTokenFr2
        
        var recoveryToken5 = CBORWebToken.mockRecoveryCertificate.extended(vaccinationQRCodeData: "9")
        recoveryToken5.vaccinationCertificate.iat = vaccinationToken3Iat
        recoveryToken5.vaccinationCertificate.hcert.dgc.r!.first!.fr = vaccinationTokenDt2
       
         
         // GIVEN about Test -> later all test should stay in array no rules
         let testTokenSc = try XCTUnwrap(DateUtils.parseDate("2022-05-01T15:05:00"))
         let testToken1Iat = try XCTUnwrap(DateUtils.parseDate("2022-07-02T15:05:00"))
         
         var testToken1 = CBORWebToken.mockTestCertificate.extended(vaccinationQRCodeData: "10")
         testToken1.vaccinationCertificate.iat = testToken1Iat
         testToken1.vaccinationCertificate.hcert.dgc.t!.first!.sc = testTokenSc

         var testToken2 = CBORWebToken.mockTestCertificate.extended(vaccinationQRCodeData: "11")
         testToken2.vaccinationCertificate.iat = testToken1Iat
         testToken2.vaccinationCertificate.hcert.dgc.t!.first!.sc = testTokenSc

         var testToken3 = CBORWebToken.mockTestCertificate.extended(vaccinationQRCodeData: "12")
         testToken3.vaccinationCertificate.iat = testToken1Iat
         testToken3.vaccinationCertificate.hcert.dgc.t!.first!.sc = testTokenSc

        let sut: [ExtendedCBORWebToken] = [vaccinationToken1,
                                           recoveryToken2,
                                           recoveryToken3,
                                           vaccinationToken2,
                                           testToken1,
                                           testToken2,
                                           recoveryToken5,
                                           testToken3,
                                           vaccinationToken3,
                                           recoveryToken4,
                                           recoveryToken1,
                                           vaccinationToken4]

        // WHEN
        let cleanSut = sut.cleanDuplicates

        // THEN
        let vaccinationCert1 = try XCTUnwrap(cleanSut[4].vaccinationCertificate)
        let vaccination1 = try XCTUnwrap(vaccinationCert1.hcert.dgc.v?.first)
        let vaccinationCert2 = try XCTUnwrap(cleanSut[6].vaccinationCertificate)
        let vaccination2 = try XCTUnwrap(vaccinationCert2.hcert.dgc.v?.first)
        let recoveryCert1 = try XCTUnwrap(cleanSut[0].vaccinationCertificate)
        let recovery1 = try XCTUnwrap(recoveryCert1.hcert.dgc.r?.first)
        let recoveryCert2 = try XCTUnwrap(cleanSut[5].vaccinationCertificate)
        let recovery2 = try XCTUnwrap(recoveryCert2.hcert.dgc.r?.first)
        XCTAssertEqual(cleanSut.count, 7)
        XCTAssertEqual(vaccinationCert1.certType, .vaccination)
        XCTAssertEqual(vaccinationCert1.iat, vaccinationToken3Iat)
        XCTAssertEqual(vaccination1.dt, vaccinationTokenDt)
        XCTAssertEqual(vaccinationCert2.certType, .vaccination)
        XCTAssertEqual(vaccinationCert2.iat, vaccinationToken3Iat)
        XCTAssertEqual(vaccination2.dt, vaccinationTokenDt2)
        XCTAssertEqual(recoveryCert1.certType, .recovery)
        XCTAssertEqual(recoveryCert1.iat, recoveryToken3Iat)
        XCTAssertEqual(recovery1.fr, recoveryTokenFr)
        XCTAssertEqual(recoveryCert2.certType, .recovery)
        XCTAssertEqual(recoveryCert2.iat, recoveryToken3Iat)
        XCTAssertEqual(recovery2.fr, recoveryTokenFr2)
    }

    func testFilterByNameDateOfBirth() {
        // Given
        var token1Owner1 = CBORWebToken.mockVaccinationCertificate
        var token2Owner1 = CBORWebToken.mockVaccinationCertificate
        var tokenOwner2 = CBORWebToken.mockVaccinationCertificate
        var tokenOwner3 = CBORWebToken.mockVaccinationCertificate
        token1Owner1.hcert.dgc = .mock(name: .mustermann())
        token2Owner1.hcert.dgc = .mock(name: .mustermann())
        tokenOwner2.hcert.dgc = .mock(name: .yildirim())
        tokenOwner3.hcert.dgc = .mock(name: .mustermann(), dob: Date())
        let sut = [
            token1Owner1.extended(),
            token2Owner1.extended(),
            tokenOwner2.extended(),
            tokenOwner3.extended()
        ]
        let dateOfBirth = tokenOwner2.hcert.dgc.dob

        // When
        let tokens = sut.filter(by: .yildirim(), dateOfBirth: dateOfBirth)

        // Then
        XCTAssertEqual(tokens.count, 1)
    }
    
    func testFilterByNameDateOfBirth_dob_is_nil() {
        // Given
        var token1Owner1 = CBORWebToken.mockVaccinationCertificate
        var token2Owner1 = CBORWebToken.mockVaccinationCertificate
        var tokenOwner2 = CBORWebToken.mockVaccinationCertificate
        var tokenOwner3 = CBORWebToken.mockVaccinationCertificate
        token1Owner1.hcert.dgc = .mock(name: .mustermann())
        token2Owner1.hcert.dgc = .mock(name: .mustermann())
        tokenOwner2.hcert.dgc = .mock(name: .yildirim())
        tokenOwner3.hcert.dgc = .mock(name: .mustermann(), dob: Date())
        let sut = [
            token1Owner1.extended(),
            token2Owner1.extended(),
            tokenOwner2.extended(),
            tokenOwner3.extended()
        ]
        let dateOfBirth: Date? = nil

        // When
        let tokens = sut.filter(by: .yildirim(), dateOfBirth: dateOfBirth)

        // Then
        XCTAssertEqual(tokens.count, 1)
    }
    
    func test_sortLatestRecoveries() {
        // Given
        let token1r = CBORWebToken.mockRecoveryCertificate
            .mockRecoverySetDate(Date() - 1)
            .extended(vaccinationQRCodeData: "1r")
        let token2r = CBORWebToken.mockRecoveryCertificate
            .mockRecoverySetDate(Date() - 3)
            .extended(vaccinationQRCodeData: "2r")
        let token1v = CBORWebToken.mockVaccinationCertificate
            .mockVaccinationSetDate(Date() + 1)
            .extended(vaccinationQRCodeData: "1v")
        let token1t = CBORWebToken.mockTestCertificate
            .mockTestSetDate(Date() - 1)
            .extended(vaccinationQRCodeData: "1t")
        let sut = [
            token1r,
            token2r,
            token1v,
            token1t
        ]

        // When
        let tokens = sut.sortLatestRecoveries

        // Then
        XCTAssertEqual(tokens.count, 2)
        XCTAssertEqual(tokens.first?.vaccinationQRCodeData, "1r")
        XCTAssertEqual(tokens.last?.vaccinationQRCodeData, "2r")
    }
    
    func test_latestRecovery() {
        // Given
        let token1r = CBORWebToken.mockRecoveryCertificate
            .mockRecoverySetDate(Date() - 1)
            .mockRecoveryUVCI("1r")
            .extended(vaccinationQRCodeData: "1r")
        let token2r = CBORWebToken.mockRecoveryCertificate
            .mockRecoverySetDate(Date() - 3)
            .mockRecoveryUVCI("2r")
            .extended(vaccinationQRCodeData: "2r")
        let token1v = CBORWebToken.mockVaccinationCertificate
            .mockVaccinationSetDate(Date() + 1)
            .mockVaccinationUVCI("1v")
            .extended(vaccinationQRCodeData: "1v")
        let token1t = CBORWebToken.mockTestCertificate
            .mockTestSetDate(Date() - 1)
            .mockTestUVCI("1t")
            .extended(vaccinationQRCodeData: "1t")
        let sut = [
            token1r,
            token2r,
            token1v,
            token1t
        ]

        // When
        let latestRecovery = sut.latestRecovery

        // Then
        XCTAssertEqual(latestRecovery?.ci, "1r")
    }
}

private extension DigitalGreenCertificate {
    static func mock(name: Name = .mustermann(), dob: Date? = nil) -> DigitalGreenCertificate {
        .init(nam: name, dob: dob, dobString: nil, v: nil, t: nil, r: nil, ver: "1.0")
    }
}

private extension Name {
    static func mustermann() -> Name {
        .init(gn: nil, fn: nil, gnt: nil, fnt: "MUSTERMANN")
    }
    static func yildirim() -> Name {
        .init(gn: nil, fn: nil, gnt: nil, fnt: "YILDIRIM")
    }
}
