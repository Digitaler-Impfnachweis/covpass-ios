//
//  CertificateHolderStatusModelTests.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CertLogic
@testable import CovPassCommon
import SwiftyJSON
import XCTest

class CertificateHolderStatusModelTests: XCTestCase {
    private var certLogic: DCCCertLogicMock!
    private var sut: CertificateHolderStatusModel!
    private var token: ExtendedCBORWebToken!
    private var rule: Rule!

    override func setUpWithError() throws {
        certLogic = .init()
        token = CBORWebToken.mockVaccinationCertificate.extended()
        rule = Rule(identifier: "FOO", type: "Invalidation", version: "", schemaVersion: "", engine: "", engineVersion: "", certificateType: "", description: [], validFrom: "", validTo: "", affectedString: [], logic: JSON(), countryCode: "")
        sut = .init(dccCertLogic: certLogic)
    }

    override func tearDownWithError() throws {
        certLogic = nil
        token = nil
        rule = nil
        sut = nil
    }

    // MARK: checkDomesticAcceptanceAndInvalidationRules

    func test_checkDomesticAcceptanceAndInvalidationRules_emptyToken() {
        // WHEN
        let result = sut.checkDomesticAcceptanceAndInvalidationRules([])
        // THEN
        XCTAssertEqual(result, .failedTechnical)
    }

    func test_checkDomesticAcceptanceAndInvalidationRules_someError() {
        // GIVEN
        certLogic.validationError = NSError(domain: "some error", code: 1)
        // WHEN
        let result = sut.checkDomesticAcceptanceAndInvalidationRules([token])
        // THEN
        XCTAssertEqual(result, .failedTechnical)
    }

    func test_checkDomesticAcceptanceAndInvalidationRules_with_ruleWhichHasTypeOfInvalidationWhichIsFailed() {
        // GIVEN
        rule.type = "Invalidation"
        certLogic.validateResult = [.init(rule: rule)]
        // WHEN
        let result = sut.checkDomesticAcceptanceAndInvalidationRules([token])
        // THEN
        XCTAssertEqual(result, .failedFunctional)
    }

    func test_checkDomesticAcceptanceAndInvalidationRules_with_ruleWhichHasTypeOfAcceptanceWhichIsFailed() {
        // GIVEN
        rule.type = "Acceptance"
        certLogic.validateResult = [.init(rule: rule, result: .fail)]
        // WHEN
        let result = sut.checkDomesticAcceptanceAndInvalidationRules([token])
        // THEN
        XCTAssertEqual(result, .failedFunctional)
    }

    func test_checkDomesticAcceptanceAndInvalidationRules_with_ruleWhichHasTypeOfAcceptanceWhichIsOpen() {
        // GIVEN
        rule.type = "Acceptance"
        certLogic.validateResult = [.init(rule: rule, result: .open)]
        // WHEN
        let result = sut.checkDomesticAcceptanceAndInvalidationRules([token])
        // THEN
        XCTAssertEqual(result, .failedFunctional)
    }

    func test_checkDomesticAcceptanceAndInvalidationRules_with_ruleWhichHasTypeOfAcceptanceWhichIsPassed() {
        // GIVEN
        rule.type = "Acceptance"
        certLogic.validateResult = [.init(rule: rule, result: .passed)]
        // WHEN
        let result = sut.checkDomesticAcceptanceAndInvalidationRules([token])
        // THEN
        XCTAssertEqual(result, .passed)
    }

    func test_ifsg22aRulesAvailable_true() {
        // GIVEN
        let expectedResult = true
        certLogic.areRulesAvailable = expectedResult
        // WHEN
        let result = sut.ifsg22aRulesAvailable()
        // THEN
        XCTAssertEqual(result, expectedResult)
    }

    func test_ifsg22aRulesAvailable_false() {
        // GIVEN
        let expectedResult = false
        certLogic.areRulesAvailable = expectedResult
        // WHEN
        let result = sut.ifsg22aRulesAvailable()
        // THEN
        XCTAssertEqual(result, expectedResult)
    }

    func test_ifsg22a_passed() {
        // GIVEN
        certLogic.validateResult = [.init(rule: rule, result: .passed)]
        // WHEN
        let result = sut.vaccinationCycleIsComplete([token])
        // THEN
        XCTAssertTrue(result.passed)
    }

    func test_ifsg22a_invalidation_rule_fails() {
        // GIVEN
        certLogic.validateResult = [.init(rule: rule, result: .fail)]
        // WHEN
        let result = sut.vaccinationCycleIsComplete([token])
        // THEN
        XCTAssertFalse(result.passed)
    }

    func test_ifsg22a_invalidation_someError() {
        // GIVEN
        certLogic.validationError = NSError(domain: "some error", code: 1)
        // WHEN
        let result = sut.vaccinationCycleIsComplete([token])
        // THEN
        XCTAssertEqual(result.passed, false)
    }
}
