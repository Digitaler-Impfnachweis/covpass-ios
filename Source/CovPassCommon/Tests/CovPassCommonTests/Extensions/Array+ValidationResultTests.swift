//
//  Array+ValidationResult.swift
//  
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import XCTest
import CertLogic
import SwiftyJSON

@testable import CovPassCommon

class ArrayValidationResultTests: XCTestCase {

    func testFailedResultsWithFailedResults() {
        // GIVEN
        let rule = Rule(identifier: "", type: "", version: "", schemaVersion: "", engine: "", engineVersion: "", certificateType: "", description: [], validFrom: "", validTo: "", affectedString: [], logic: JSON(""), countryCode: "DE")
        let sut: [ValidationResult] = [.init(rule: rule, result: .fail, validationErrors: nil)]
        // WHEN
        let failedResults = sut.failedResults
        // THEN
        XCTAssertFalse(failedResults.isEmpty)
    }
    
    func testFailedResultsWithPassedResults() {
        // GIVEN
        let rule = Rule(identifier: "", type: "", version: "", schemaVersion: "", engine: "", engineVersion: "", certificateType: "", description: [], validFrom: "", validTo: "", affectedString: [], logic: JSON(""), countryCode: "DE")
        let sut: [ValidationResult] = [.init(rule: rule, result: .passed, validationErrors: nil)]
        // WHEN
        let failedResults = sut.failedResults
        // THEN
        XCTAssertTrue(failedResults.isEmpty)
    }
    
    func testFailedResultsWithOpenResults() {
        // GIVEN
        let rule = Rule(identifier: "", type: "", version: "", schemaVersion: "", engine: "", engineVersion: "", certificateType: "", description: [], validFrom: "", validTo: "", affectedString: [], logic: JSON(""), countryCode: "DE")
        let sut: [ValidationResult] = [.init(rule: rule, result: .open, validationErrors: nil)]
        // WHEN
        let failedResults = sut.failedResults
        // THEN
        XCTAssertTrue(failedResults.isEmpty)
    }
    
    func testOpenResultsWithFailedResults() {
        // GIVEN
        let rule = Rule(identifier: "", type: "", version: "", schemaVersion: "", engine: "", engineVersion: "", certificateType: "", description: [], validFrom: "", validTo: "", affectedString: [], logic: JSON(""), countryCode: "DE")
        let sut: [ValidationResult] = [.init(rule: rule, result: .fail, validationErrors: nil)]
        // WHEN
        let failedResults = sut.openResults
        // THEN
        XCTAssertTrue(failedResults.isEmpty)
    }
    
    func testOpenResultsWithPassedResults() {
        // GIVEN
        let rule = Rule(identifier: "", type: "", version: "", schemaVersion: "", engine: "", engineVersion: "", certificateType: "", description: [], validFrom: "", validTo: "", affectedString: [], logic: JSON(""), countryCode: "DE")
        let sut: [ValidationResult] = [.init(rule: rule, result: .passed, validationErrors: nil)]
        // WHEN
        let failedResults = sut.openResults
        // THEN
        XCTAssertTrue(failedResults.isEmpty)
    }
    
    func testOpenResultsWithOpenResults() {
        // GIVEN
        let rule = Rule(identifier: "", type: "", version: "", schemaVersion: "", engine: "", engineVersion: "", certificateType: "", description: [], validFrom: "", validTo: "", affectedString: [], logic: JSON(""), countryCode: "DE")
        let sut: [ValidationResult] = [.init(rule: rule, result: .open, validationErrors: nil)]
        // WHEN
        let failedResults = sut.openResults
        // THEN
        XCTAssertFalse(failedResults.isEmpty)
    }
    
    func testResultOf() {
        // GIVEN
        let rule = Rule(identifier: "FOO", type: "", version: "", schemaVersion: "", engine: "", engineVersion: "", certificateType: "", description: [], validFrom: "", validTo: "", affectedString: [], logic: JSON(""), countryCode: "DE")
        let sut: [ValidationResult] = [.init(rule: rule, result: .open, validationErrors: nil)]
        // WHEN
        let fetechedResult = sut.result(ofRule: "FOO")
        // THEN
        XCTAssertEqual(sut.first!.result, fetechedResult)
    }
    
    func testValidationResultOf() {
        // GIVEN
        let rule = Rule(identifier: "FOO", type: "", version: "", schemaVersion: "", engine: "", engineVersion: "", certificateType: "", description: [], validFrom: "", validTo: "", affectedString: [], logic: JSON(""), countryCode: "DE")
        let sut: [ValidationResult] = [.init(rule: rule, result: .open, validationErrors: nil)]
        // WHEN
        let fetechedResult = sut.validationResult(ofRule: "FOO")
        // THEN
        XCTAssertEqual(rule.identifier, fetechedResult?.rule?.identifier)
    }
    
    func testfilteringOfAcceptanceRules() {
        // GIVEN
        let rule = Rule(identifier: "FOO", type: "Acceptance", version: "", schemaVersion: "", engine: "", engineVersion: "", certificateType: "", description: [], validFrom: "", validTo: "", affectedString: [], logic: JSON(""), countryCode: "DE")
        let rule2 = Rule(identifier: "Bar", type: "Invalidation", version: "", schemaVersion: "", engine: "", engineVersion: "", certificateType: "", description: [], validFrom: "", validTo: "", affectedString: [], logic: JSON(""), countryCode: "DE")
        let sut: [ValidationResult] = [.init(rule: rule, result: .open, validationErrors: nil),
            .init(rule: rule2, result: .open, validationErrors: nil)]
        // WHEN
        let fetechedResult = sut.filterAcceptanceRules
        // THEN
        XCTAssertEqual(fetechedResult.count, 1)
        XCTAssertEqual(rule.identifier, fetechedResult.first?.rule?.identifier)
    }
    
    func testFilterAcceptanceAndInvalidationRules() {
        // GIVEN
        let rule = Rule(identifier: "FOO", type: "Acceptance", version: "", schemaVersion: "", engine: "", engineVersion: "", certificateType: "", description: [], validFrom: "", validTo: "", affectedString: [], logic: JSON(""), countryCode: "DE")
        let rule2 = Rule(identifier: "Bar", type: "Invalidation", version: "", schemaVersion: "", engine: "", engineVersion: "", certificateType: "", description: [], validFrom: "", validTo: "", affectedString: [], logic: JSON(""), countryCode: "DE")
        let rule3 = Rule(identifier: "Bar", type: "Mask", version: "", schemaVersion: "", engine: "", engineVersion: "", certificateType: "", description: [], validFrom: "", validTo: "", affectedString: [], logic: JSON(""), countryCode: "DE")
        let sut: [ValidationResult] = [.init(rule: rule, result: .open, validationErrors: nil),
                                       .init(rule: rule3, result: .open, validationErrors: nil),
                                       .init(rule: rule2, result: .open, validationErrors: nil)]
        // WHEN
        let fetechedResult = sut.filterAcceptanceAndInvalidationRules
        // THEN
        XCTAssertEqual(fetechedResult.count, 2)
        XCTAssertEqual(rule.identifier, fetechedResult.first?.rule?.identifier)
        XCTAssertEqual(rule2.identifier, fetechedResult.last?.rule?.identifier)
    }
    
    func testFilterFailedAndOpenResults() {
        // GIVEN
        let sut: [ValidationResult] = [.init(rule: nil, result: .open, validationErrors: nil),
                                       .init(rule: nil, result: .open, validationErrors: nil),
                                       .init(rule: nil, result: .open, validationErrors: nil)]
        // WHEN
        let fetechedResult = sut.failedAndOpenResults
        // THEN
        XCTAssertEqual(fetechedResult.count, 3)
    }
    
    func testFilterFailedAndOpenResults_Alternative() {
        // GIVEN
        let sut: [ValidationResult] = [.init(rule: nil, result: .open, validationErrors: nil),
                                       .init(rule: nil, result: .passed, validationErrors: nil),
                                       .init(rule: nil, result: .fail, validationErrors: nil)]
        // WHEN
        let fetechedResult = sut.failedAndOpenResults
        // THEN
        XCTAssertEqual(fetechedResult.count, 2)
    }
    
    func testFilterInvalidationRules() {
        // GIVEN
        let rule = Rule(identifier: "FOO", type: "Acceptance", version: "", schemaVersion: "", engine: "", engineVersion: "", certificateType: "", description: [], validFrom: "", validTo: "", affectedString: [], logic: JSON(""), countryCode: "DE")
        let rule2 = Rule(identifier: "Bar", type: "Invalidation", version: "", schemaVersion: "", engine: "", engineVersion: "", certificateType: "", description: [], validFrom: "", validTo: "", affectedString: [], logic: JSON(""), countryCode: "DE")
        let rule3 = Rule(identifier: "Tst", type: "Mask", version: "", schemaVersion: "", engine: "", engineVersion: "", certificateType: "", description: [], validFrom: "", validTo: "", affectedString: [], logic: JSON(""), countryCode: "DE")
        let sut: [ValidationResult] = [.init(rule: rule, result: .open, validationErrors: nil),
                                       .init(rule: rule2, result: .passed, validationErrors: nil),
                                       .init(rule: rule3, result: .fail, validationErrors: nil)]
        // WHEN
        let fetechedResult = sut.filterInvalidationRules
        // THEN
        XCTAssertEqual(fetechedResult.count, 1)
        XCTAssertEqual(fetechedResult.first?.rule?.identifier, "Bar")
    }
}
