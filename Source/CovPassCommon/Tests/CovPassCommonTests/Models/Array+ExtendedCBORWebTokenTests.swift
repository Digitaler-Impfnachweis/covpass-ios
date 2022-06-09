//
//  Array+ExtendedCBORWebTokenTests.swift
//  
//
//  Created by Thomas Kuleßa on 23.02.22.
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
        let token2 = CBORWebToken.mockVaccinationCertificate.extended(vaccinationQRCodeData: "2")
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

        let cborToken1 = CBORWebToken.mockRecoveryCertificate.mockRecovery(fr: now-2)
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
