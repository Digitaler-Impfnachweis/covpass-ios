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
    private var certLogic: DCCCertLogicMock!
    private var sut: CertificateHolderStatusModel!
    private var token: ExtendedCBORWebToken!
    private var rule: Rule!
    private let maskStatusRuleTypeIdentifier = "Mask"
    
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
    
    func test_checkDomesticAcceptanceAndInvalidationRules_with_ruleWhichHasTypeMaskWhichIsFailed() {
        // GIVEN
        rule.type = "Mask"
        certLogic.validateResult = [.init(rule: rule, result: .fail)]
        // WHEN
        let result = sut.checkDomesticAcceptanceAndInvalidationRules([token])
        // THEN
        XCTAssertEqual(result, .failedTechnical)
    }
    
    func test_checkDomesticAcceptanceAndInvalidationRules_with_ruleWhichHasTypeMaskWhichIsPassed() {
        // GIVEN
        rule.type = "Mask"
        certLogic.validateResult = [.init(rule: rule, result: .passed)]
        // WHEN
        let result = sut.checkDomesticAcceptanceAndInvalidationRules([token])
        // THEN
        XCTAssertEqual(result, .failedTechnical)
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
    
    // MARK: checkEuInvalidationRules
    
    func test_checkEuInvalidationRules_emptyToken() {
        // WHEN
        let result = sut.checkEuInvalidationRules([])
        // THEN
        XCTAssertEqual(result, .failedTechnical)
    }
    
    func test_checkEuInvalidationRules_someError() {
        // GIVEN
        certLogic.validationError = NSError(domain: "some error", code: 1)
        // WHEN
        let result = sut.checkEuInvalidationRules([token])
        // THEN
        XCTAssertEqual(result, .failedTechnical)
    }
    
    func test_checkEuInvalidationRuless_with_ruleWhichHasTypeOfInvalidationWhichIsFailed() {
        // GIVEN
        rule.type = "Invalidation"
        certLogic.validateResult = [.init(rule: rule)]
        // WHEN
        let result = sut.checkEuInvalidationRules([token])
        // THEN
        XCTAssertEqual(result, .failedFunctional)
    }
    
    func test_checkEuInvalidationRules_with_ruleWhichHasTypeMaskWhichIsFailed() {
        // GIVEN
        rule.type = "Mask"
        certLogic.validateResult = [.init(rule: rule, result: .fail)]
        // WHEN
        let result = sut.checkEuInvalidationRules([token])
        // THEN
        XCTAssertEqual(result, .failedFunctional)
    }
    
    func test_checkEuInvalidationRules_with_ruleWhichHasTypeMaskWhichIsPassed() {
        // GIVEN
        rule.type = "Mask"
        certLogic.validateResult = [.init(rule: rule, result: .passed)]
        // WHEN
        let result = sut.checkEuInvalidationRules([token])
        // THEN
        XCTAssertEqual(result, .passed)
    }
    
    func test_checkEuInvalidationRules_with_ruleWhichHasTypeOfInvalidationWhichIsFailed() {
        // GIVEN
        rule.type = "Invalidation"
        certLogic.validateResult = [.init(rule: rule, result: .fail)]
        // WHEN
        let result = sut.checkEuInvalidationRules([token])
        // THEN
        XCTAssertEqual(result, .failedFunctional)
    }
    
    func test_checkEuInvalidationRules_with_ruleWhichHasTypeOfInvalidationWhichIsOpen() {
        // GIVEN
        rule.type = "Invalidation"
        certLogic.validateResult = [.init(rule: rule, result: .open)]
        // WHEN
        let result = sut.checkEuInvalidationRules([token])
        // THEN
        XCTAssertEqual(result, .failedFunctional)
    }
    
    func test_checkEuInvalidationRules_with_ruleWhichHasTypeOfInvalidationWhichIsPassed() {
        // GIVEN
        rule.type = "Invalidation"
        certLogic.validateResult = [.init(rule: rule, result: .passed)]
        // WHEN
        let result = sut.checkEuInvalidationRules([token])
        // THEN
        XCTAssertEqual(result, .passed)
    }
    
    // MARK: holderIsFullyImmunized
    
    func test_holderIsFullyImmunized_emptyToken() {
        // GIVEN
        // WHEN
        let result = sut.holderIsFullyImmunized([])
        // THEN
        XCTAssertEqual(result, false)
    }
    
    func test_holderIsFullyImmunized_someError() {
        // GIVEN
        certLogic.validationError = NSError(domain: "some error", code: 1)
        // WHEN
        let result = sut.holderIsFullyImmunized([token])
        // THEN
        XCTAssertEqual(result, false)
    }
    
    func test_holderIsFullyImmunized_noAcceptanceOrInvalidationRulesAvailable_inResult() {
        // GIVEN
        rule.type = "Mask"
        certLogic.validateResult = [.init(rule: rule, result: .passed)]
        // WHEN
        let result = sut.holderIsFullyImmunized([token])
        // THEN
        XCTAssertEqual(result, false)
    }
    
    func test_holderIsFullyImmunized_Failed_AcceptanceRuleAvailable_inResult() {
        // GIVEN
        rule.type = "Acceptance"
        certLogic.validateResult = [.init(rule: rule, result: .fail)]
        // WHEN
        let result = sut.holderIsFullyImmunized([token])
        // THEN
        XCTAssertEqual(result, false)
    }
    
    func test_holderIsFullyImmunized_Open_AcceptanceRuleAvailable_inResult() {
        // GIVEN
        rule.type = "Acceptance"
        certLogic.validateResult = [.init(rule: rule, result: .open)]
        // WHEN
        let result = sut.holderIsFullyImmunized([token])
        // THEN
        XCTAssertEqual(result, false)
    }
    
    func test_holderIsFullyImmunized_Failed_InvalidationRuleAvailable_inResult() {
        // GIVEN
        rule.type = "Invalidation"
        certLogic.validateResult = [.init(rule: rule, result: .fail)]
        // WHEN
        let result = sut.holderIsFullyImmunized([token])
        // THEN
        XCTAssertEqual(result, false)
    }
    
    func test_holderIsFullyImmunized_Open_InvalidationRuleAvailable_inResult() {
        // GIVEN
        rule.type = "Invalidation"
        certLogic.validateResult = [.init(rule: rule, result: .open)]
        // WHEN
        let result = sut.holderIsFullyImmunized([token])
        // THEN
        XCTAssertEqual(result, false)
    }
    
    func test_holderIsFullyImmunized_Passed_AcceptanceRuleAvailable_inResult() {
        // GIVEN
        rule.type = "Acceptance"
        certLogic.validateResult = [.init(rule: rule, result: .passed)]
        // WHEN
        let result = sut.holderIsFullyImmunized([token])
        // THEN
        XCTAssertEqual(result, true)
    }
    
    func test_holderIsFullyImmunized_Passed_InvalidationRuleAvailable_inResult() {
        // GIVEN
        rule.type = "Invalidation"
        certLogic.validateResult = [.init(rule: rule, result: .passed)]
        // WHEN
        let result = sut.holderIsFullyImmunized([token])
        // THEN
        XCTAssertEqual(result, true)
    }
    
    
    // MARK: holderNeedsMask
    
    func test_holderNeedsMask_emptyToken() {
        // WHEN
        let result = sut.holderNeedsMask([], region: nil)
        // THEN
        XCTAssertEqual(result, true)
    }
    
    func test_holderNeedsMask_someError() {
        // GIVEN
        certLogic.validationError = NSError(domain: "some error", code: 1)
        // WHEN
        let result = sut.holderNeedsMask([token], region: nil)
        // THEN
        XCTAssertEqual(result, true)
    }
    
    func test_holderNeedsMask_Failed_inResult() {
        // GIVEN
        rule.type = "Mask"
        certLogic.validateResult = [.init(rule: rule, result: .fail)]
        // WHEN
        let result = sut.holderNeedsMask([token], region: nil)
        // THEN
        XCTAssertEqual(result, true)
    }
    
    func test_holderNeedsMask_Open_inResult() {
        // GIVEN
        rule.type = "Acceptance"
        certLogic.validateResult = [.init(rule: rule, result: .open)]
        // WHEN
        let result = sut.holderNeedsMask([token], region: nil)
        // THEN
        XCTAssertEqual(result, true)
    }
    
    func test_holderNeedsMask_Passed_ButNotMaskRule_inResult() {
        // GIVEN
        rule.type = "Acceptance"
        certLogic.validateResult = [.init(rule: rule, result: .passed)]
        // WHEN
        let result = sut.holderNeedsMask([token], region: nil)
        // THEN
        XCTAssertEqual(result, true)
    }
    
    func test_holderNeedsMask_Passed_MaskRule_inResult() {
        // GIVEN
        rule.type = maskStatusRuleTypeIdentifier
        certLogic.validateResult = [.init(rule: rule, result: .passed)]
        // WHEN
        let result = sut.holderNeedsMask([token], region: nil)
        // THEN
        XCTAssertEqual(result, false)
    }
    
    func test_holderNeedsMaskAsync_Passed_MaskRule_inResult() {
        // GIVEN
        let expectation = XCTestExpectation(description: "Should have same result like non async method")
        rule.type = maskStatusRuleTypeIdentifier
        certLogic.validateResult = [.init(rule: rule, result: .passed)]
        // WHEN
        sut.holderNeedsMaskAsync([token], region: nil)
            .done { result in
                XCTAssertEqual(result, false)
                expectation.fulfill()
            }
        // THEN
        wait(for: [expectation], timeout: 1)
    }
    
    // MARK: maskRulesAvailable
    
    func test_maskRulesAvailable_true() {
        // GIVEN
        let expectedResult = true
        certLogic.areRulesAvailable = expectedResult
        // WHEN
        let result = sut.maskRulesAvailable(for: nil)
        // THEN
        XCTAssertEqual(result, expectedResult)
    }
    
    func test_maskRulesAvailable_false() {
        // GIVEN
        let expectedResult = false
        certLogic.areRulesAvailable = expectedResult
        // WHEN
        let result = sut.maskRulesAvailable(for: nil)
        // THEN
        XCTAssertEqual(result, expectedResult)
    }
}
