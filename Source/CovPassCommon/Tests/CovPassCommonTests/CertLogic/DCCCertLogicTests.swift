//
//  DCCCertLogicTests.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CertLogic
@testable import CovPassCommon
import Foundation
import PromiseKit
import SwiftyJSON
import XCTest

class DCCCertLogicTests: XCTestCase {
    var keychain: MockPersistence!
    var userDefaults: MockPersistence!
    var service: DCCServiceMock!
    var sut: DCCCertLogic!
    var repository: VaccinationRepositoryProtocol!

    override func setUp() {
        super.setUp()
        keychain = MockPersistence()
        userDefaults = MockPersistence()
        service = DCCServiceMock()
        sut = DCCCertLogic(initialDCCRulesURL: Bundle.commonBundle.url(forResource: "dcc-rules", withExtension: "json")!, service: service, keychain: keychain, userDefaults: userDefaults)

        let trustListURL = Bundle.commonBundle.url(forResource: "dsc.json", withExtension: nil)!
        repository = VaccinationRepository(service: APIServiceMock(), keychain: MockPersistence(), userDefaults: MockPersistence(), publicKeyURL: URL(fileURLWithPath: "pubkey.pem"), initialDataURL: trustListURL)
    }

    override func tearDown() {
        keychain = nil
        service = nil
        sut = nil
        repository = nil
        super.tearDown()
    }

    func testErrorCode() {
        XCTAssertEqual(DCCCertLogicError.noRules.errorCode, 601)
        XCTAssertEqual(DCCCertLogicError.encodingError.errorCode, 602)
    }

    func testCountries() {
        XCTAssertEqual(sut.countries.count, 31)
    }

    func testLocalValueSets() {
        XCTAssertEqual(sut.valueSets.count, 8)
        XCTAssertEqual(sut.valueSets["country-2-codes"]?.count, 249)
        XCTAssertEqual(sut.valueSets["covid-19-lab-result"]?.count, 2)
        XCTAssertEqual(sut.valueSets["covid-19-lab-test-manufacturer-and-name"]?.count, 140)
        XCTAssertEqual(sut.valueSets["covid-19-lab-test-type"]?.count, 2)
        XCTAssertEqual(sut.valueSets["disease-agent-targeted"]?.count, 1)
        XCTAssertEqual(sut.valueSets["sct-vaccines-covid-19"]?.count, 3)
        XCTAssertEqual(sut.valueSets["vaccines-covid-19-auth-holders"]?.count, 15)
        XCTAssertEqual(sut.valueSets["vaccines-covid-19-names"]?.count, 13)
    }

    func testRemoteValueSets() throws {
        let data = try JSONEncoder().encode([ValueSet(id: "valueSet", hash: "1", data: Data())])
        try userDefaults.store(UserDefaults.keyValueSets, value: data)

        XCTAssertEqual(sut.valueSets.count, 1)
        XCTAssertEqual(sut.valueSets["valueSet"]?.count, 0)
    }

    func testLastUpdatedDCCRules() throws {
        XCTAssertNil(sut.lastUpdatedDCCRules())

        let date = Date()
        try userDefaults.store(UserDefaults.keyLastUpdatedDCCRules, value: date)

        XCTAssertEqual(sut.lastUpdatedDCCRules(), date)
    }

    func testUpdateRulesIfNeeded() throws {
        service.loadValueSetsResult = Promise.value([])
        try sut.updateRulesIfNeeded().wait()

        do {
            try sut.updateRulesIfNeeded().wait()
            XCTFail("Should fail")
        } catch {
            XCTAssertEqual(error.localizedDescription, PromiseCancelledError().localizedDescription)
        }
    }

    func testSavedAndLocalRules() throws {
        // Check local rules (no saved rules)
        XCTAssertEqual(sut.dccRules?.count, 109)

        // Save one rule
        let rule = Rule(identifier: "", type: "", version: "", schemaVersion: "", engine: "", engineVersion: "", certificateType: "", description: [], validFrom: "", validTo: "", affectedString: [], logic: JSON(""), countryCode: "")
        rule.hash = "1"
        let data = try JSONEncoder().encode([rule])
        try keychain.store(KeychainPersistence.dccRulesKey, value: data)

        // Check saved rules
        XCTAssertEqual(sut.dccRules?.count, 1)
    }

    func testValidVaccination() throws {
        let cert = try repository.checkCertificate(CertificateMock.validCertificate).wait()

        let res = try sut.validate(countryCode: "DE", validationClock: Date(), certificate: cert)

        XCTAssertEqual(res.count, 4)
        XCTAssertEqual(failedResults(results: res).count, 0)
    }

    func testInvalidVaccination() throws {
        let cert = try repository.checkCertificate(CertificateMock.validCertificate).wait()
        cert.hcert.dgc.v![0].dt = Date(timeIntervalSince1970: 0)

        let res = try sut.validate(countryCode: "DE", validationClock: Date(), certificate: cert)

        XCTAssertEqual(res.count, 4)
        XCTAssertEqual(failedResults(results: res).count, 1)
        XCTAssertEqual(failedResults(results: res)[0].rule?.identifier, "VR-DE-0004")
    }

    func testValidVaccinationWithoutRules() {
        do {
            let sut = DCCCertLogic(initialDCCRulesURL: Bundle.commonBundle.url(forResource: "dsc", withExtension: "json")!, service: DCCServiceMock(), keychain: MockPersistence(), userDefaults: MockPersistence())
            let cert = try repository.checkCertificate(CertificateMock.validCertificate).wait()

            _ = try sut.validate(countryCode: "DE", validationClock: Date(), certificate: cert)

            XCTFail("Test should fail without rules")
        } catch {
            XCTAssertEqual(error.localizedDescription, DCCCertLogicError.noRules.localizedDescription)
        }
    }

    func testValidRecovery() throws {
        let cert = try repository.checkCertificate(CertificateMock.validRecoveryCertificate).wait()

        let res = try sut.validate(countryCode: "DE", validationClock: Date(), certificate: cert)

        XCTAssertEqual(res.count, 2)
        XCTAssertEqual(failedResults(results: res).count, 0)
    }

    func testInvalidRecovery() throws {
        let cert = try repository.checkCertificate(CertificateMock.validRecoveryCertificate).wait()
        cert.hcert.dgc.r![0].fr = Date(timeIntervalSince1970: 0)

        let res = try sut.validate(countryCode: "DE", validationClock: Date(), certificate: cert)

        XCTAssertEqual(res.count, 2)
        XCTAssertEqual(failedResults(results: res).count, 1)
        XCTAssertEqual(failedResults(results: res)[0].rule?.identifier, "RR-DE-0002")
    }

    func testRuleUpdate() throws {
        // Initial keychain should be empty
        let noData = try keychain.fetch(KeychainPersistence.dccRulesKey)
        XCTAssertNil(noData)

        // Update rules
        service.loadDCCRulesResult = Promise.value([RuleSimple(identifier: "", version: "", country: "DE", hash: "")])
        service.loadDCCRuleResult = Promise.value(Rule(identifier: "", type: "", version: "", schemaVersion: "", engine: "", engineVersion: "", certificateType: "", description: [], validFrom: "", validTo: "", affectedString: [], logic: JSON(""), countryCode: "DE"))
        service.loadValueSetsResult = Promise.value([])
        try sut.updateRules().wait()

        // Keychain should have the new rules
        let data = try keychain.fetch(KeychainPersistence.dccRulesKey)! as! Data
        let rules = try JSONDecoder().decode([Rule].self, from: data)
        XCTAssertEqual(rules.count, 1)
    }

    func testRuleUpdateNothingNew() throws {
        let rule = Rule(identifier: "", type: "", version: "", schemaVersion: "", engine: "", engineVersion: "", certificateType: "", description: [], validFrom: "", validTo: "", affectedString: [], logic: JSON(""), countryCode: "DE")

        // Load intial data
        let initialData = try JSONEncoder().encode([rule])
        try keychain.store(KeychainPersistence.dccRulesKey, value: initialData)

        // Update rules
        service.loadDCCRulesResult = Promise.value([RuleSimple(identifier: "", version: "", country: "DE", hash: "")])
        service.loadDCCRuleResult = Promise.value(rule)
        service.loadValueSetsResult = Promise.value([])
        try sut.updateRules().wait()

        // Keychain should have the new rules
        let data = try keychain.fetch(KeychainPersistence.dccRulesKey)! as! Data
        let rules = try JSONDecoder().decode([Rule].self, from: data)
        XCTAssertEqual(rules.count, 1)
    }

    func testRuleUpdateNewRule() throws {
        // Load intial data
        let initialRule = Rule(identifier: "2", type: "", version: "", schemaVersion: "", engine: "", engineVersion: "", certificateType: "", description: [], validFrom: "", validTo: "", affectedString: [], logic: JSON(""), countryCode: "DE")
        initialRule.hash = "2"
        let initialData = try JSONEncoder().encode([initialRule])
        try keychain.store(KeychainPersistence.dccRulesKey, value: initialData)

        // Update rules
        service.loadDCCRulesResult = Promise.value([
            RuleSimple(identifier: "1", version: "", country: "DE", hash: "1"),
            RuleSimple(identifier: "2", version: "", country: "DE", hash: "2")
        ])
        let rule = Rule(identifier: "1", type: "", version: "", schemaVersion: "", engine: "", engineVersion: "", certificateType: "", description: [], validFrom: "", validTo: "", affectedString: [], logic: JSON(""), countryCode: "DE")
        rule.hash = "1"
        service.loadDCCRuleResult = Promise.value(rule)
        service.loadValueSetsResult = Promise.value([])
        try sut.updateRules().wait()

        // Keychain should have the new rules
        let data = try keychain.fetch(KeychainPersistence.dccRulesKey)! as! Data
        let rules = try JSONDecoder().decode([Rule].self, from: data)
        XCTAssertEqual(rules.count, 2)
    }

    func testRuleUpdateDeleteOldRule() throws {
        // Load intial data
        let initialData = try JSONEncoder().encode([Rule(identifier: "2", type: "", version: "", schemaVersion: "", engine: "", engineVersion: "", certificateType: "", description: [], validFrom: "", validTo: "", affectedString: [], logic: JSON(""), countryCode: "DE")])
        try keychain.store(KeychainPersistence.dccRulesKey, value: initialData)

        // Update rules
        service.loadDCCRulesResult = Promise.value([RuleSimple(identifier: "1", version: "", country: "DE", hash: "1")])
        let rule = Rule(identifier: "1", type: "", version: "", schemaVersion: "", engine: "", engineVersion: "", certificateType: "", description: [], validFrom: "", validTo: "", affectedString: [], logic: JSON(""), countryCode: "DE")
        rule.hash = "1"
        service.loadDCCRuleResult = Promise.value(rule)
        service.loadValueSetsResult = Promise.value([])
        try sut.updateRules().wait()

        // Keychain should have the new rules
        let data = try keychain.fetch(KeychainPersistence.dccRulesKey)! as! Data
        let rules = try JSONDecoder().decode([Rule].self, from: data)
        XCTAssertEqual(rules.count, 1)
        XCTAssertEqual(rules[0].identifier, "1")
    }

    func testValueSetUpdate() throws {
        // Initial UserDefaults should be empty
        let noData = try userDefaults.fetch(UserDefaults.keyValueSets)
        XCTAssertNil(noData)

        // Update valueSets
        service.loadDCCRulesResult = Promise.value([])
        service.loadValueSetsResult = Promise.value([["id": "1", "hash": "1"]])
        service.loadValueSetResult = Promise.value(CovPassCommon.ValueSet(id: "1", hash: "1", data: Data()))
        try sut.updateRules().wait()

        // UserDefaults should have the new value sets
        let data = try userDefaults.fetch(UserDefaults.keyValueSets)! as! Data
        let valueSets = try JSONDecoder().decode([CovPassCommon.ValueSet].self, from: data)
        XCTAssertEqual(valueSets.count, 1)
    }

    func testValueSetUpdateDeleteOldRule() throws {
        // Load intial data
        let initialData = try JSONEncoder().encode([CovPassCommon.ValueSet(id: "2", hash: "", data: Data())])
        try userDefaults.store(UserDefaults.keyValueSets, value: initialData)

        // Update valueSets
        service.loadDCCRulesResult = Promise.value([])
        service.loadValueSetsResult = Promise.value([["id": "1", "hash": "1"]])
        service.loadValueSetResult = Promise.value(CovPassCommon.ValueSet(id: "1", hash: "1", data: Data()))
        try sut.updateRules().wait()

        // UserDefaults should have the new value sets
        let data = try userDefaults.fetch(UserDefaults.keyValueSets)! as! Data
        let valueSets = try JSONDecoder().decode([CovPassCommon.ValueSet].self, from: data)
        XCTAssertEqual(valueSets.count, 1)
        XCTAssertEqual(valueSets[0].id, "1")
    }

    func testValueSetUpdateNothingNew() throws {
        // Load intial data
        let initialData = try JSONEncoder().encode([CovPassCommon.ValueSet(id: "1", hash: "1", data: Data())])
        try userDefaults.store(UserDefaults.keyValueSets, value: initialData)

        // Update valueSets
        service.loadDCCRulesResult = Promise.value([])
        service.loadValueSetsResult = Promise.value([["id": "1", "hash": "1"]])
        try sut.updateRules().wait()

        // UserDefaults should have the new value sets
        let data = try userDefaults.fetch(UserDefaults.keyValueSets)! as! Data
        let valueSets = try JSONDecoder().decode([CovPassCommon.ValueSet].self, from: data)
        XCTAssertEqual(valueSets.count, 1)
    }

    // MARK: - Helpers

    private func failedResults(results: [ValidationResult]) -> [ValidationResult] {
        results.filter { $0.result == .fail }
    }
}
