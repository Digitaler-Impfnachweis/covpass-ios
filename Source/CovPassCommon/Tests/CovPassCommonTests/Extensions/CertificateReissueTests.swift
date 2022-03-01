//
//  ReIssueTests.swift
//  
//
//  Created by Fatih Karakurt on 25.02.22.
//

import Foundation
import CovPassCommon
import XCTest

class CertificateReissueTests: XCTestCase{
    
    let singleDoseImmunizationJohnsonCert = CBORWebToken.mockVaccinationCertificate
        .mockVaccinationUVCI("1")
        .medicalProduct(.johnsonjohnson)
        .doseNumber(1)
        .seriesOfDoses(1)
        .extended(vaccinationQRCodeData: "1")
    let vaccinationWithTwoShotsOfVaccine = CBORWebToken.mockVaccinationCertificate
        .mockVaccinationUVCI("2")
        .medicalProduct(.biontech)
        .doseNumber(2)
        .seriesOfDoses(2)
        .extended(vaccinationQRCodeData: "2")
    let recoveryCert = CBORWebToken.mockRecoveryCertificate
        .mockRecoveryUVCI("3")
        .extended(vaccinationQRCodeData: "3")
    let someOtherCert1 = CBORWebToken.mockVaccinationCertificate
        .mockVaccinationUVCI("4")
        .medicalProduct(.biontech)
        .doseNumber(1)
        .seriesOfDoses(2)
        .extended(vaccinationQRCodeData: "4")
    let someOtherCert2 = CBORWebToken.mockTestCertificate
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
}
