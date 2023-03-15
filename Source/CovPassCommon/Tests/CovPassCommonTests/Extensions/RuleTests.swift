//
//  RuleTests.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CertLogic
import Foundation
import SwiftyJSON
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

    func test_is_invalidationRule() {
        // GIVEN
        let rule = Rule(type: RuleType.invalidation.rawValue)
        // WHEN
        let isInvalidationRule = rule.isInvalidationRule
        // THEN
        XCTAssertTrue(isInvalidationRule)
    }

    func test_isNot_invalidationRule() {
        // GIVEN
        let rule = Rule(type: RuleType.acceptence.rawValue)
        // WHEN
        let isInvalidationRule = rule.isInvalidationRule
        // THEN
        XCTAssertFalse(isInvalidationRule)
    }

    func test_is_acceptenceRule() {
        // GIVEN
        let rule = Rule(type: RuleType.acceptence.rawValue)
        // WHEN
        let isAcceptence = rule.isAcceptence
        // THEN
        XCTAssertTrue(isAcceptence)
    }

    func test_isNot_acceptenceRule() {
        // GIVEN
        let rule = Rule(type: RuleType.invalidation.rawValue)
        // WHEN
        let isAcceptence = rule.isAcceptence
        // THEN
        XCTAssertFalse(isAcceptence)
    }

    func test_isNot_acceptenceRuleOrInvalidationRule() {
        // GIVEN
        let rule = Rule(type: "Foo")
        // WHEN
        let isAcceptenceOrInvalidationRule = rule.isAcceptenceOrInvalidationRule
        // THEN
        XCTAssertTrue(isAcceptenceOrInvalidationRule)
    }

    func test_filter_acceptenceRules() {
        // GIVEN
        let invalidationRule = Rule(identifier: "1", type: RuleType.invalidation.rawValue)
        let acceptenceRule = Rule(identifier: "2", type: RuleType.acceptence.rawValue)
        let rules = [invalidationRule, acceptenceRule]
        // WHEN
        let acceptanceRules = rules.acceptanceRules
        // THEN
        XCTAssertNotNil(acceptanceRules)
        XCTAssertEqual(acceptanceRules.count, 1)
        XCTAssertEqual(acceptanceRules[0].identifier, "2")
    }

    func test_filter_acceptenceRules_empty_result() {
        // GIVEN
        let invalidationRule = Rule(identifier: "1", type: RuleType.invalidation.rawValue)
        let acceptenceRule = Rule(identifier: "2", type: RuleType.invalidation.rawValue)
        let rules = [invalidationRule, acceptenceRule]
        // WHEN
        let acceptanceRules = rules.acceptanceRules
        // THEN
        XCTAssertNotNil(acceptanceRules)
        XCTAssertEqual(acceptanceRules.count, 0)
        XCTAssertEqual(acceptanceRules.isEmpty, true)
    }

    func test_filter_invalidationRules() {
        // GIVEN
        let invalidationRule = Rule(identifier: "1", type: RuleType.invalidation.rawValue)
        let acceptenceRule = Rule(identifier: "2", type: RuleType.acceptence.rawValue)
        let rules = [invalidationRule, acceptenceRule]
        // WHEN
        let invalidationRules = rules.invalidationRules
        // THEN
        XCTAssertNotNil(invalidationRules)
        XCTAssertEqual(invalidationRules.count, 1)
        XCTAssertEqual(invalidationRules[0].identifier, "1")
    }

    func test_filter_acceptenceAndInvalidationRules() {
        // GIVEN
        let invalidationRule = Rule(identifier: "1", type: RuleType.invalidation.rawValue)
        let acceptenceRule = Rule(identifier: "2", type: RuleType.acceptence.rawValue)
        let rules = [invalidationRule, acceptenceRule]
        // WHEN
        let acceptenceAndInvalidationRules = rules.acceptenceAndInvalidationRules
        // THEN
        XCTAssertNotNil(acceptenceAndInvalidationRules)
        XCTAssertEqual(acceptenceAndInvalidationRules.count, 2)
        XCTAssertEqual(acceptenceAndInvalidationRules[0].identifier, "1")
        XCTAssertEqual(acceptenceAndInvalidationRules[1].identifier, "2")
    }

    func test_filter_invalidationRules_empty_result() {
        // GIVEN
        let invalidationRule = Rule(identifier: "1", type: RuleType.invalidation.rawValue)
        let acceptenceRule = Rule(identifier: "2", type: RuleType.invalidation.rawValue)
        let rules = [invalidationRule, acceptenceRule]
        // WHEN
        let invalidationRules = rules.invalidationRules
        // THEN
        XCTAssertNotNil(invalidationRules)
        XCTAssertEqual(invalidationRules.count, 2)
        XCTAssertEqual(invalidationRules.isEmpty, false)
    }

    func test_is_Ifsg22aRules_ImpfstatusBZwei() {
        // GIVEN
        let sut = Rule(identifier: "1", type: "ImpfstatusBZwei")
        // WHEN
        let isIfsg22aRule = sut.isIfsg22aRule
        // THEN
        XCTAssertTrue(isIfsg22aRule)
    }

    func test_is_Ifsg22aRules_ImpfstatusCZwei() {
        // GIVEN
        let sut = Rule(identifier: "1", type: "ImpfstatusCZwei")
        // WHEN
        let isIfsg22aRule = sut.isIfsg22aRule
        // THEN
        XCTAssertTrue(isIfsg22aRule)
    }

    func test_is_Ifsg22aRules_ImpfstatusEZwei() {
        // GIVEN
        let sut = Rule(identifier: "1", type: "ImpfstatusEZwei")
        // WHEN
        let isIfsg22aRule = sut.isIfsg22aRule
        // THEN
        XCTAssertTrue(isIfsg22aRule)
    }

    func test_isNot_Ifsg22aRules_ImpfstatusBZwei() {
        // GIVEN
        let sut = Rule(identifier: "1", type: "ImpfstatusBZweiNOT")
        // WHEN
        let isIfsg22aRule = sut.isIfsg22aRule
        // THEN
        XCTAssertFalse(isIfsg22aRule)
    }

    func test_isNot_Ifsg22aRules_ImpfstatusCZwei() {
        // GIVEN
        let sut = Rule(identifier: "1", type: "ImpfstatusCZweiNOT")
        // WHEN
        let isIfsg22aRule = sut.isIfsg22aRule
        // THEN
        XCTAssertFalse(isIfsg22aRule)
    }

    func test_isNot_Ifsg22aRules_ImpfstatusEZwei() {
        // GIVEN
        let sut = Rule(identifier: "1", type: "ImpfstatusEZweiNOT")
        // WHEN
        let isIfsg22aRule = sut.isIfsg22aRule
        // THEN
        XCTAssertFalse(isIfsg22aRule)
    }

    func test_is_Ifsg22aRules() {
        // GIVEN
        let rule1 = Rule(identifier: "1", type: "ImpfstatusEZwei")
        let rule2 = Rule(identifier: "1", type: "ImpfstatusCZwei")
        let rule3 = Rule(identifier: "1", type: "ImpfstatusBZwei")
        let rule4 = Rule(identifier: "1", type: RuleType.acceptence.rawValue)
        let rule5 = Rule(identifier: "MA-DE-0100", type: RuleType.mask.rawValue)
        let rule6 = Rule(identifier: "1", type: RuleType._2G.rawValue)
        let rule7 = Rule(identifier: "1", type: RuleType._3G.rawValue)
        let rule8 = Rule(identifier: "1", type: "ImpfstatusEEins")
        let sut = [rule1, rule2, rule3, rule4, rule5, rule6, rule7, rule8]
        // WHEN
        let ifsg22aRules = sut.ifsg22aRules
        // THEN
        XCTAssertEqual(ifsg22aRules.count, 4)
    }

    func test_isNoRuleIdentifier_true() {
        // GIVEN
        let sut = Rule(identifier: "GR-DE-0001")
        // WHEN
        let isNoRuleIdentifier = sut.isNoRuleIdentifier
        // THEN
        XCTAssertTrue(isNoRuleIdentifier)
    }

    func test_isNoRuleIdentifier_false() {
        // GIVEN
        let sut = Rule(identifier: "FOO")
        // WHEN
        let isNoRuleIdentifier = sut.isNoRuleIdentifier
        // THEN
        XCTAssertFalse(isNoRuleIdentifier)
    }

    func test_localizedDescription_de() {
        // GIVEN
        let description: [Description] = [.init(lang: "en", desc: "This is a description"),
                                          .init(lang: "de", desc: "Das ist eine Beschreibung"),
                                          .init(lang: "tr", desc: "Bu bir açıklama"),
                                          .init(lang: "sp", desc: "esta es una descripcion"),
                                          .init(lang: "fr", desc: "Ceci est un descriptif"),
                                          .init(lang: "it", desc: "Questa è una descrizione")]
        let sut = Rule(identifier: "FOO", description: description)
        // WHEN
        let localizedDescription = sut.localizedDescription(for: "de")
        // THEN
        XCTAssertEqual(localizedDescription, "Das ist eine Beschreibung")
    }

    func test_localizedDescription_it() {
        // GIVEN
        let description: [Description] = [.init(lang: "en", desc: "This is a description"),
                                          .init(lang: "de", desc: "Das ist eine Beschreibung"),
                                          .init(lang: "tr", desc: "Bu bir açıklama"),
                                          .init(lang: "sp", desc: "esta es una descripcion"),
                                          .init(lang: "fr", desc: "Ceci est un descriptif"),
                                          .init(lang: "it", desc: "Questa è una descrizione")]
        let sut = Rule(identifier: "FOO", description: description)
        // WHEN
        let localizedDescription = sut.localizedDescription(for: "it")
        // THEN
        XCTAssertEqual(localizedDescription, "Questa è una descrizione")
    }

    func test_localizedDescription_none() {
        // GIVEN
        let description: [Description] = [.init(lang: "en", desc: "This is a description"),
                                          .init(lang: "de", desc: "Das ist eine Beschreibung"),
                                          .init(lang: "tr", desc: "Bu bir açıklama"),
                                          .init(lang: "sp", desc: "esta es una descripcion"),
                                          .init(lang: "fr", desc: "Ceci est un descriptif"),
                                          .init(lang: "it", desc: "Questa è una descrizione")]
        let sut = Rule(identifier: "FOO", description: description)
        // WHEN
        let localizedDescription = sut.localizedDescription(for: "pl")
        // THEN
        XCTAssertEqual(localizedDescription, nil)
    }
}
