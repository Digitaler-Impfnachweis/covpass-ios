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

class ArrayValidationResult: XCTestCase {

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
}
