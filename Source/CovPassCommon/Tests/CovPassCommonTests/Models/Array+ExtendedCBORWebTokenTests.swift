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
        let candidateForReissue = certs.filterBoosterAfterVaccinationAfterRecovery
        
        // THEN
        XCTAssertFalse(candidateForReissue.isEmpty)
        XCTAssertTrue(candidateForReissue.count == 2)
        XCTAssertTrue(candidateForReissue.contains(singleDoseImmunizationJohnsonCert))
        XCTAssertTrue(candidateForReissue.contains(vaccinationWithTwoShotsOfVaccine))
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
        let candidateForReissue = certs.filterBoosterAfterVaccinationAfterRecovery
        
        // THEN
        XCTAssertTrue(certs.qualifiedForReissue)
        XCTAssertFalse(candidateForReissue.isEmpty)
        XCTAssertTrue(candidateForReissue.count == 2)
        XCTAssertTrue(candidateForReissue.contains(singleDoseImmunizationJohnsonCert))
        XCTAssertTrue(candidateForReissue.contains(vaccinationWithTwoShotsOfVaccine))
        XCTAssertFalse(candidateForReissue.contains(someOtherCert1))
        XCTAssertFalse(candidateForReissue.contains(someOtherCert2))
    }
    
    func testBoosterAfterVaccinationAfterRecoveryWithRecovery() {
        // GIVEN
        let certs = [someOtherCert2,
                     recoveryCert2,
                     singleDoseImmunizationJohnsonCert,
                     someOtherCert1,
                     vaccinationWithTwoShotsOfVaccine,
                     recoveryCert]
        
        // WHEN
        let candidateForReissue = certs.filterBoosterAfterVaccinationAfterRecovery
        
        // THEN
        XCTAssertTrue(certs.qualifiedForReissue)
        XCTAssertFalse(candidateForReissue.isEmpty)
        XCTAssertEqual(candidateForReissue.count, 4)
        XCTAssertTrue(candidateForReissue.contains(singleDoseImmunizationJohnsonCert))
        XCTAssertTrue(candidateForReissue.contains(vaccinationWithTwoShotsOfVaccine))
        XCTAssertTrue(candidateForReissue.contains(recoveryCert))
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
