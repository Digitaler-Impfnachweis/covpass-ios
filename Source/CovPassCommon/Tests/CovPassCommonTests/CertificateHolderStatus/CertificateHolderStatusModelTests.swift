//
//  CertificateHolderStatusModelTests.swift
//  
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassCommon
import XCTest
import CertLogic
import SwiftyJSON

class CertificateHolderStatusModelTests: XCTestCase {
    private var dccCertLogic: DCCCertLogicMock!
    private var sut: CertificateHolderStatusModel!

    override func setUpWithError() throws {
        dccCertLogic = .init()
        sut = .init(
            dccCertLogic: dccCertLogic
        )
    }

    override func tearDownWithError() throws {
        dccCertLogic = nil
        sut = nil
    }

    func testHolderIsFullyImmunized_vaccinationRepository_has_error() {
        // Given

        // When
        let isFullyImmunized = sut.holderIsFullyImmunized([])

        // Then
        XCTAssertFalse(isFullyImmunized)
    }
    
    func testHolderIsFullyImmunized_unkown_user() {
        // Given

        // When
        let isFullyImmunized = sut.holderIsFullyImmunized([])

        // Then
        XCTAssertFalse(isFullyImmunized)
    }
    
    func test_holderIsFullyImmunized_false() {
        // Given
        let ruleType = "TwoGPlus"
        let validationResultValue = Result.passed

        let token1 = CBORWebToken.mockVaccinationCertificate.extended()
        let rule = Rule(identifier: "", type: ruleType, version: "", schemaVersion: "", engine: "", engineVersion: "", certificateType: "", description: [], validFrom: "", validTo: "", affectedString: [], logic: JSON(""), countryCode: "")
        let validationResult = ValidationResult(rule: rule, result: validationResultValue, validationErrors: [])

        dccCertLogic.validateResult = [validationResult]

        // When
        let isFullyImmunized = sut.holderIsFullyImmunized([token1])

        // Then
        XCTAssertFalse(isFullyImmunized)
    }
    
    func test_holderIsFullyImmunized_true() {
        // Given
        let ruleType = "Acceptance"
        let validationResultValue = Result.passed

        let token1 = CBORWebToken.mockVaccinationCertificate.extended()
        let rule = Rule(identifier: "", type: ruleType, version: "", schemaVersion: "", engine: "", engineVersion: "", certificateType: "", description: [], validFrom: "", validTo: "", affectedString: [], logic: JSON(""), countryCode: "")
        let validationResult = ValidationResult(rule: rule, result: validationResultValue, validationErrors: [])

        dccCertLogic.validateResult = [validationResult]

        // When
        let isFullyImmunized = sut.holderIsFullyImmunized([token1])

        // Then
        XCTAssertTrue(isFullyImmunized)
    }
    
    func test_holderIsFullyImmunized_false_due_error() {
        // Given
        let token1 = CBORWebToken.mockVaccinationCertificate.extended()
        dccCertLogic.validationError = NSError(domain: "", code: 1)

        // When
        let isFullyImmunized = sut.holderIsFullyImmunized([token1])

        // Then
        XCTAssertFalse(isFullyImmunized)
    }

    func testHoldeNeedsMask_vaccinationRepository_has_error() {
        // Given

        // When
        let needsMask = sut.holderNeedsMask([])

        // Then
        XCTAssertTrue(needsMask)
    }
}
