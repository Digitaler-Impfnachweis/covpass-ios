//
//  RuleTests.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import SwiftyJSON
import CertLogic
import XCTest

@testable import CovPassCommon

class RuleTests: XCTestCase {
    func testRuleEquatable() {
        let rule1 = Rule(identifier: "1", type: "1", version: "1", schemaVersion: "1", engine: "1", engineVersion: "1", certificateType: "1", description: [], validFrom: "1", validTo: "1", affectedString: [], logic: JSON(), countryCode: "1")
        let rule2 = Rule(identifier: "2", type: "2", version: "2", schemaVersion: "2", engine: "2", engineVersion: "2", certificateType: "2", description: [], validFrom: "2", validTo: "2", affectedString: [], logic: JSON(), countryCode: "2")

        XCTAssertEqual(rule1, rule1)
        XCTAssertEqual(rule2, rule2)
        XCTAssertNotEqual(rule1, rule2)
    }
}
