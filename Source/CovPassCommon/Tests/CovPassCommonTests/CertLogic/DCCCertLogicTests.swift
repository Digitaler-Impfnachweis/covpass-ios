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
    let jsonDecoder = JSONDecoder()

    override func setUp() {
        super.setUp()
        keychain = MockPersistence()
        userDefaults = MockPersistence()
        service = DCCServiceMock()
        sut = DCCCertLogic(initialDCCRulesURL: Bundle.commonBundle.url(forResource: "dcc-rules", withExtension: "json")!,
                           initialDomesticDCCRulesURL: Bundle.commonBundle.url(forResource: "dcc-domestic-rules", withExtension: "json")!,
                           service: service,
                           keychain: keychain,
                           userDefaults: userDefaults)

        let trustListURL = Bundle.commonBundle.url(forResource: "dsc.json", withExtension: nil)!
        repository = VaccinationRepository(
            revocationRepo: CertificateRevocationRepositoryMock(),
            service: APIServiceMock(),
            keychain: MockPersistence(),
            userDefaults: MockPersistence(),
            boosterLogic: BoosterLogicMock(),
            publicKeyURL: URL(fileURLWithPath: "pubkey.pem"),
            initialDataURL: trustListURL,
            queue: .global()
        )
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
        XCTAssertEqual(sut.countries.count, 43)
    }

    func testLocalValueSets() {
        XCTAssertEqual(sut.valueSets.count, 8)
        XCTAssertEqual(sut.valueSets["country-2-codes"]?.count, 250)
        XCTAssertEqual(sut.valueSets["covid-19-lab-result"]?.count, 2)
        XCTAssertEqual(sut.valueSets["covid-19-lab-test-manufacturer-and-name"]?.count, 266)
        XCTAssertEqual(sut.valueSets["covid-19-lab-test-type"]?.count, 2)
        XCTAssertEqual(sut.valueSets["disease-agent-targeted"]?.count, 1)
        XCTAssertEqual(sut.valueSets["sct-vaccines-covid-19"]?.count, 6)
        XCTAssertEqual(sut.valueSets["vaccines-covid-19-auth-holders"]?.count, 30)
        XCTAssertEqual(sut.valueSets["vaccines-covid-19-names"]?.count, 37)
    }

    func testRemoteValueSets() throws {
        let data = try JSONEncoder().encode([ValueSet(id: "valueSet", hash: "1", data: Data())])
        userDefaults.valueSets = data

        XCTAssertEqual(sut.valueSets.count, 1)
        XCTAssertEqual(sut.valueSets["valueSet"]?.count, 0)
    }

    func testUpdateRulesIfNeededTrue() throws {
        let dateDefault = Date().addingTimeInterval(-100_000_000)
        userDefaults.lastUpdatedDCCRules = dateDefault
        service.loadBoosterRulesResult = Promise.value([])

        let lastUpdateDateBefore = try XCTUnwrap(userDefaults.lastUpdatedDCCRules)
        XCTAssertEqual(dateDefault, lastUpdateDateBefore)
        service.loadValueSetsResult = Promise.value([])
        try sut.updateRulesIfNeeded().wait()
        let lastUpdateDateAfter = try XCTUnwrap(userDefaults.lastUpdatedDCCRules)
        XCTAssertNotNil(lastUpdateDateAfter)
        XCTAssertNotEqual(dateDefault, lastUpdateDateAfter)
    }

    func testUpdateRulesIfNeededFalse() throws {
        let dateDefault = Date()
        userDefaults.lastUpdatedDCCRules = dateDefault
        service.loadBoosterRulesResult = Promise.value([])

        let lastUpdateDateBefore = try XCTUnwrap(userDefaults.lastUpdatedDCCRules)
        XCTAssertEqual(dateDefault, lastUpdateDateBefore)
        try sut.updateRulesIfNeeded().wait()
        let lastUpdateDateAfter = userDefaults.lastUpdatedDCCRules
        XCTAssertNotNil(lastUpdateDateAfter)
        XCTAssertEqual(dateDefault, lastUpdateDateAfter)
    }

    func testUpdateDomesticRulesIfNeededTrue() {
        let expectation = XCTestExpectation()
        let lastUpdateDomesticRules = Date() - 100_000_000
        userDefaults.lastUpdateDomesticRules = lastUpdateDomesticRules
        sut.updateDomesticIfNeeded().done { _ in
            let lastUpdateDateAfter = try XCTUnwrap(self.userDefaults.lastUpdateDomesticRules)
            XCTAssertNotEqual(lastUpdateDomesticRules, lastUpdateDateAfter)
            expectation.fulfill()
        }.catch { error in
            XCTFail("Should not fail \(error)")
        }
        wait(for: [expectation], timeout: 0.1)
    }

    func testUpdateDomesticRulesIfNeededFalse() {
        let expectation = XCTestExpectation()
        let lastUpdateDomesticRules = Date()
        userDefaults.lastUpdateDomesticRules = lastUpdateDomesticRules
        sut.updateDomesticIfNeeded().done { _ in
            let lastUpdateDateAfter = try XCTUnwrap(self.userDefaults.lastUpdateDomesticRules)
            XCTAssertEqual(lastUpdateDomesticRules, lastUpdateDateAfter)
            expectation.fulfill()
        }.catch { error in
            XCTFail("Should not fail \(error)")
        }
        wait(for: [expectation], timeout: 0.1)
    }

    func testSavedAndLocalRules() throws {
        // Check local rules (no saved rules)
        XCTAssertEqual(sut.dccRules.count, 300)

        // Save one rule
        let rule = Rule(identifier: "", type: "", version: "", schemaVersion: "", engine: "", engineVersion: "", certificateType: "", description: [], validFrom: "", validTo: "", affectedString: [], logic: JSON(""), countryCode: "")
        rule.hash = "1"
        let data = try JSONEncoder().encode([rule])
        try XCTUnwrap(keychain.store(KeychainPersistence.Keys.dccRules.rawValue, value: data))

        // Check saved rules
        XCTAssertEqual(sut.dccRules.count, 1)
    }

    func testValidVaccination() throws {
        let cert = try repository.checkCertificate(CertificateMock.validCertificate2, checkSealCertificate: false).wait()

        let res = try sut.validate(countryCode: "DE", validationClock: Date(), certificate: cert)

        XCTAssertEqual(res.count, 1)
        XCTAssertEqual(res.failedResults.count, 0)
    }

//    func testInvalidVaccinationDE() throws {
//        let cert = try repository.checkCertificate(CertificateMock.validCertificate2).wait()
//        cert.hcert.dgc.v![0].dt = Date(timeIntervalSince1970: 0)
//
//        let res = try sut.validate(type: .de,countryCode: "DE", validationClock: Date(), certificate: cert)
//
//        XCTAssertEqual(res.count, 4)
//        XCTAssertEqual(res.failedResults.count, 0)
//        XCTAssertEqual(res.failedResults.first?.rule?.identifier, nil)
//    }

    func testInvalidVaccinationEU() throws {
        let cert = try repository.checkCertificate(CertificateMock.validCertificate2, checkSealCertificate: false).wait()
        cert.hcert.dgc.v![0].dt = Date(timeIntervalSince1970: 0)

        let res = try sut.validate(type: .eu, countryCode: "DE", validationClock: Date(), certificate: cert)

        XCTAssertEqual(res.count, 1)
        XCTAssertEqual(res.failedResults.count, 0)
        XCTAssertEqual(res.failedResults.first?.rule?.identifier, nil)
    }

    func testValidVaccinationWithoutRules() {
        do {
            let sut = DCCCertLogic(initialDCCRulesURL: Bundle.commonBundle.url(forResource: "dsc", withExtension: "json")!,
                                   initialDomesticDCCRulesURL: Bundle.commonBundle.url(forResource: "dcc-domestic-rules", withExtension: "json")!,
                                   service: DCCServiceMock(),
                                   keychain: MockPersistence(),
                                   userDefaults: MockPersistence())
            let cert = try repository.checkCertificate(CertificateMock.validCertificate2, checkSealCertificate: false).wait()

            _ = try sut.validate(countryCode: "DE", validationClock: Date(), certificate: cert)

            XCTFail("Test should fail without rules")
        } catch {
            XCTAssertEqual(error.localizedDescription, DCCCertLogicError.noRules.localizedDescription)
        }
    }

    func testValidRecovery() throws {
        let cert = CBORWebToken.mockRecoveryCertificate
        cert.hcert.dgc.r!.first!.fr = try XCTUnwrap(Calendar.current.date(byAdding: .day, value: -29, to: Date()))
        let res = try sut.validate(countryCode: "DE", validationClock: Date(), certificate: cert)

        XCTAssertEqual(res.count, 1)
        XCTAssertEqual(res.failedResults.count, 0)
    }

//    func testInvalidRecoveryDE() throws {
//        let cert = try repository.checkCertificate(CertificateMock.validRecoveryCertificate).wait()
//        cert.hcert.dgc.r![0].fr = Date(timeIntervalSince1970: 0)
//
//        let res = try sut.validate(type: .de, countryCode: "DE", validationClock: Date(), certificate: cert)
//
//        XCTAssertEqual(res.count, 2)
//        XCTAssertEqual(res.failedResults.count, 1)
//        XCTAssertEqual(res.failedResults.first?.rule?.identifier, "RR-DE-0002")
//    }

//    func testDomesticRulesCount() {
//        let dccDomesticRules = sut.dccDomesticRules
//        XCTAssertEqual(dccDomesticRules.count, 12)
//        XCTAssertEqual(dccDomesticRules.acceptenceAndInvalidationRules.count, 12)
//    }

    func testInvalidRecoveryEU() throws {
        let cert = try repository.checkCertificate(CertificateMock.validRecoveryCertificate, checkSealCertificate: false).wait()
        cert.hcert.dgc.r![0].fr = Date(timeIntervalSince1970: 0)

        let res = try sut.validate(type: .eu, countryCode: "DE", validationClock: Date(), certificate: cert)

        XCTAssertEqual(res.count, 1)
        XCTAssertEqual(res.failedResults.count, 0)
    }

    func testRuleUpdate() throws {
        // Initial keychain should be empty
        let noData = try keychain.fetch(KeychainPersistence.Keys.dccRules.rawValue)
        XCTAssertNil(noData)

        // Update rules
        service.loadDCCRulesResult = Promise.value([RuleSimple.mock])
        service.loadDCCRuleResult = Promise.value(Rule.mock)
        service.loadBoosterRulesResult = Promise.value([RuleSimple.mock])
        service.loadBoosterRuleResult = Promise.value(Rule.mock)
        service.loadDomesticDCCRulesResult = Promise.value([RuleSimple.mock])
        service.loadDomesticDCCRuleResult = Promise.value(Rule.mock)
        service.loadValueSetsResult = Promise.value([])
        try sut.updateRules().wait()
        try sut.updateBoosterRules().wait()

        // Keychain should have the new rules
        let dccData = try XCTUnwrap(keychain.fetch(KeychainPersistence.Keys.dccRules.rawValue) as? Data)
        let dccRules = try jsonDecoder.decode([Rule].self, from: dccData)
        XCTAssertEqual(dccRules.count, 1)
        let boosterData = try XCTUnwrap(keychain.fetch(KeychainPersistence.Keys.boosterRules.rawValue) as? Data)
        let boosterRules = try jsonDecoder.decode([Rule].self, from: boosterData)
        XCTAssertEqual(boosterRules.count, 1)
        let domesticData = try XCTUnwrap(keychain.fetch(KeychainPersistence.Keys.dccDomesticRules.rawValue) as? Data)
        let domesticRules = try jsonDecoder.decode([Rule].self, from: domesticData)
        XCTAssertEqual(domesticRules.count, 1)
    }

    func testRuleUpdateNothingNew() throws {
        // Load intial data
        let initialData = try JSONEncoder().encode([Rule.mock])
        try XCTUnwrap(keychain.store(KeychainPersistence.Keys.dccRules.rawValue, value: initialData))

        // Update rules
        service.loadDCCRulesResult = Promise.value([RuleSimple.mock])
        service.loadDCCRuleResult = Promise.value(Rule.mock)
        service.loadBoosterRulesResult = Promise.value([RuleSimple.mock])
        service.loadBoosterRuleResult = Promise.value(Rule.mock)
        service.loadDomesticDCCRulesResult = Promise.value([RuleSimple.mock])
        service.loadDomesticDCCRuleResult = Promise.value(Rule.mock)
        service.loadValueSetsResult = Promise.value([])
        try sut.updateRules().wait()
        try sut.updateBoosterRules().wait()

        // Keychain should have the new rules
        let dccData = try XCTUnwrap(keychain.fetch(KeychainPersistence.Keys.dccRules.rawValue) as? Data)
        let dccRules = try jsonDecoder.decode([Rule].self, from: dccData)
        XCTAssertEqual(dccRules.count, 1)
        let boosterData = try XCTUnwrap(keychain.fetch(KeychainPersistence.Keys.boosterRules.rawValue) as? Data)
        let boosterRules = try jsonDecoder.decode([Rule].self, from: boosterData)
        XCTAssertEqual(boosterRules.count, 1)
        let domesticData = try XCTUnwrap(keychain.fetch(KeychainPersistence.Keys.dccDomesticRules.rawValue) as? Data)
        let domesticRules = try jsonDecoder.decode([Rule].self, from: domesticData)
        XCTAssertEqual(domesticRules.count, 1)
    }

    func testRuleUpdateNewRule() throws {
        // Load intial data
        let initialData = try JSONEncoder().encode([Rule.mock.setIdentifier("2").setHash("2")])
        try XCTUnwrap(keychain.store(KeychainPersistence.Keys.dccRules.rawValue, value: initialData))
        try XCTUnwrap(keychain.store(KeychainPersistence.Keys.dccDomesticRules.rawValue, value: initialData))
        try XCTUnwrap(keychain.store(KeychainPersistence.Keys.boosterRules.rawValue, value: initialData))

        // Update rules
        service.loadDCCRulesResult = Promise.value([
            RuleSimple.mock.setIdentifier("1").setHash("1"),
            RuleSimple.mock.setIdentifier("2").setHash("2")
        ])
        service.loadDCCRuleResult = Promise.value(Rule.mock.setIdentifier("1").setHash("1"))
        service.loadValueSetsResult = Promise.value([])
        service.loadBoosterRulesResult = Promise.value([
            RuleSimple.mock.setIdentifier("1").setHash("1"),
            RuleSimple.mock.setIdentifier("2").setHash("2")
        ])
        service.loadBoosterRuleResult = Promise.value(Rule.mock.setIdentifier("1").setHash("1"))
        service.loadDomesticDCCRulesResult = Promise.value([
            RuleSimple.mock.setIdentifier("3").setHash("3"),
            RuleSimple.mock.setIdentifier("4").setHash("4")
        ])
        service.loadDomesticDCCRuleResult = Promise.value(Rule.mock.setIdentifier("3").setHash("3"))
        try sut.updateRules().wait()
        try sut.updateBoosterRules().wait()

        // Keychain should have the new rules
        let dccData = try XCTUnwrap(keychain.fetch(KeychainPersistence.Keys.dccRules.rawValue) as? Data)
        let dccRules = try jsonDecoder.decode([Rule].self, from: dccData)
        XCTAssertEqual(dccRules.count, 2)
        let boosterData = try XCTUnwrap(keychain.fetch(KeychainPersistence.Keys.boosterRules.rawValue) as? Data)
        let boosterRules = try jsonDecoder.decode([Rule].self, from: boosterData)
        XCTAssertEqual(boosterRules.count, 2)
        let domesticData = try XCTUnwrap(keychain.fetch(KeychainPersistence.Keys.dccDomesticRules.rawValue) as? Data)
        let domesticRules = try jsonDecoder.decode([Rule].self, from: domesticData)
        XCTAssertEqual(domesticRules.count, 2)
    }

    func testRuleUpdateDeleteOldRule() throws {
        // Load intial data
        let initialData = try JSONEncoder().encode([Rule.mock.setIdentifier("2")])
        try XCTUnwrap(keychain.store(KeychainPersistence.Keys.dccRules.rawValue, value: initialData))
        try XCTUnwrap(keychain.store(KeychainPersistence.Keys.boosterRules.rawValue, value: initialData))

        // Update rules
        service.loadDCCRulesResult = Promise.value([RuleSimple.mock.setIdentifier("1").setHash("1")])
        service.loadDCCRuleResult = Promise.value(Rule.mock.setIdentifier("1").setHash("1"))
        service.loadDomesticDCCRulesResult = Promise.value([RuleSimple.mock.setIdentifier("2").setHash("2")])
        service.loadDomesticDCCRuleResult = Promise.value(Rule.mock.setIdentifier("2").setHash("2"))
        service.loadValueSetsResult = Promise.value([])
        service.loadBoosterRulesResult = Promise.value([RuleSimple.mock.setIdentifier("1").setHash("1")])
        service.loadBoosterRuleResult = Promise.value(Rule.mock.setIdentifier("1").setHash("1"))
        try sut.updateRules().wait()
        try sut.updateBoosterRules().wait()

        // Keychain should have the new rules
        let dccData = try XCTUnwrap(keychain.fetch(KeychainPersistence.Keys.dccRules.rawValue) as? Data)
        let dccRules = try jsonDecoder.decode([Rule].self, from: dccData)
        XCTAssertEqual(dccRules.count, 1)
        XCTAssertEqual(dccRules[0].identifier, "1")
        let dccDomesticData = try XCTUnwrap(keychain.fetch(KeychainPersistence.Keys.dccDomesticRules.rawValue) as? Data)
        let dccDomesticRules = try jsonDecoder.decode([Rule].self, from: dccDomesticData)
        XCTAssertEqual(dccDomesticRules.count, 1)
        XCTAssertEqual(dccDomesticRules[0].identifier, "2")
        let boosterData = try XCTUnwrap(keychain.fetch(KeychainPersistence.Keys.boosterRules.rawValue) as? Data)
        let boosterRules = try jsonDecoder.decode([Rule].self, from: boosterData)
        XCTAssertEqual(boosterRules.count, 1)
        XCTAssertEqual(boosterRules[0].identifier, "1")
    }

    func testValueSetUpdate() throws {
        // Initial UserDefaults should be empty
        let noData = userDefaults.valueSets
        XCTAssertNil(noData)

        // Update valueSets
        service.loadValueSetsResult = Promise.value([["id": "1", "hash": "1"]])
        service.loadValueSetResult = Promise.value(CovPassCommon.ValueSet(id: "1", hash: "1", data: Data()))
        try sut.updateValueSets().wait()

        // UserDefaults should have the new value sets
        let data = try XCTUnwrap(userDefaults.valueSets)
        let valueSets = try jsonDecoder.decode([CovPassCommon.ValueSet].self, from: data)
        XCTAssertEqual(valueSets.count, 1)
    }

    func testValueSetUpdateDeleteOldRule() throws {
        // Load intial data
        let initialData = try JSONEncoder().encode([CovPassCommon.ValueSet(id: "2", hash: "", data: Data())])
        userDefaults.valueSets = initialData

        // Update valueSets
        service.loadValueSetsResult = Promise.value([["id": "1", "hash": "1"]])
        service.loadValueSetResult = Promise.value(CovPassCommon.ValueSet(id: "1", hash: "1", data: Data()))
        try sut.updateValueSets().wait()

        // UserDefaults should have the new value sets
        let data = try XCTUnwrap(userDefaults.valueSets)
        let valueSets = try jsonDecoder.decode([CovPassCommon.ValueSet].self, from: data)
        XCTAssertEqual(valueSets.count, 1)
        XCTAssertEqual(valueSets[0].id, "1")
    }

    func testValueSetUpdateNothingNew() throws {
        // Load intial data
        let initialData = try JSONEncoder().encode([CovPassCommon.ValueSet(id: "1", hash: "1", data: Data())])
        userDefaults.valueSets = initialData

        // Update valueSets
        service.loadDCCRulesResult = Promise.value([])
        service.loadValueSetsResult = Promise.value([["id": "1", "hash": "1"]])
        service.loadBoosterRulesResult = Promise.value([])
        service.loadDomesticDCCRulesResult = Promise.value([])
        try sut.updateRules().wait()

        // UserDefaults should have the new value sets
        let data = try XCTUnwrap(userDefaults.valueSets)
        let valueSets = try jsonDecoder.decode([CovPassCommon.ValueSet].self, from: data)
        XCTAssertEqual(valueSets.count, 1)
    }

    func testUpdateDomesticRules() throws {
        // GIVEN
        try XCTUnwrap(keychain.store(KeychainPersistence.Keys.dccDomesticRules.rawValue, value: []))
        service.loadDomesticDCCRulesResult = Promise.value([RuleSimple.mock])
        service.loadDomesticDCCRuleResult = Promise.value(Rule.mock)

        // WHEN
        try sut.updateDomesticRules().wait()

        // THEN
        let domesticData = try XCTUnwrap(keychain.fetch(KeychainPersistence.Keys.dccDomesticRules.rawValue) as? Data)
        let domesticRules = try jsonDecoder.decode([Rule].self, from: domesticData)
        XCTAssertEqual(domesticRules.count, 1)
    }

    func testUpdateBoosterRuleIfNeeded() {
        let exp = expectation(description: "Update If Needed")
        // GIVEN
        userDefaults.lastUpdatedBoosterRules = Date()
        // WHEN
        sut.updateBoosterRulesIfNeeded()
            .done {
                // THEN
                exp.fulfill()
            }.cauterize()
        wait(for: [exp], timeout: 0.1, enforceOrder: true)
    }

    func testUpdateValueSetIfNeeded() {
        let exp = expectation(description: "Update If Needed")
        // GIVEN
        userDefaults.lastUpdatedValueSets = Date()
        // WHEN
        sut.updateValueSetsIfNeeded()
            .done {
                // THEN
                exp.fulfill()
            }.cauterize()
        wait(for: [exp], timeout: 0.1, enforceOrder: true)
    }

    func test_domesticRules_gStatus() throws {
        // WHEN
        let token = CBORWebToken.mockVaccinationCertificate
        XCTAssertNoThrow(try sut.validate(type: .gStatus, countryCode: "DE", validationClock: Date(), certificate: token))
    }

    func test_domesticRules_maskStatus() throws {
        // WHEN
        let token = CBORWebToken.mockVaccinationCertificate
        XCTAssertThrowsError(try sut.validate(type: .maskStatus, countryCode: "DE", validationClock: Date(), certificate: token))
    }

    func test_rules_regionAT_rulesEU() {
        // WHEN
        let rules = sut.rules(logicType: .eu, region: "AT")
        // THEN
        XCTAssertEqual(rules.count, 14)
    }

    func test_rulesAvailable_regionAT_rulesEU() {
        // WHEN
        let rulesAvailable = sut.rulesAvailable(logicType: .eu, region: "AT")
        // THEN
        XCTAssertTrue(rulesAvailable)
    }

    func test_rulesAvailable_regionNIL_rulesEU() {
        // WHEN
        let rulesAvailable = sut.rulesAvailable(logicType: .eu, region: nil)
        // THEN
        XCTAssertTrue(rulesAvailable)
    }

    func test_rulesNotAvailable_regionBLA_rulesEU() {
        // WHEN
        let rulesAvailable = sut.rulesAvailable(logicType: .eu, region: "BLA")
        // THEN
        XCTAssertFalse(rulesAvailable)
    }

    func test_rulesNotAvailable_regionNW_rulesMask() {
        // WHEN
        let rulesAvailable = sut.rulesAvailable(logicType: .maskStatus, region: "BLA")
        // THEN
        XCTAssertFalse(rulesAvailable)
    }

    func test_rulesNotAvailable_regionNIL_euInvalidation() {
        // WHEN
        let rulesAvailable = sut.rulesAvailable(logicType: .euInvalidation, region: nil)
        // THEN
        XCTAssertTrue(rulesAvailable)
    }

    func test_rulesNotAvailable_regionNW_euInvalidation() {
        // WHEN
        let rulesAvailable = sut.rulesAvailable(logicType: .euInvalidation, region: "BLA")
        // THEN
        XCTAssertFalse(rulesAvailable)
    }

    func test_rulesAvailable_ifsg22a() {
        // WHEN
        let rulesAvailable = sut.rulesAvailable(logicType: .ifsg22a, region: nil)
        // THEN
        XCTAssert(rulesAvailable)
    }

    func test_ifsg22a_ImpfstatusCZwei_pass() throws {
        // GIVEN
        let token = CBORWebToken
            .mockVaccinationCertificate
            .doseNumber(3)
            .seriesOfDoses(3)
            .medicalProduct(.biontech)
        // WHEN
        let validationResult = try? sut.validate(type: .ifsg22a,
                                                 countryCode: "DE",
                                                 validationClock: Date(),
                                                 certificate: token)
        // THEN
        XCTAssertTrue(true)
        #warning("TODO: enable after rules arrived in Production")
//        XCTAssertEqual(validationResult?.passedResults.count, 1)
//        XCTAssertEqual(validationResult!.passedResults.first!.rule!.type, "ImpfstatusCZwei")
//        XCTAssertEqual(validationResult?.failedResults.count, 2)
//        XCTAssertEqual(validationResult?.openResults.count, 0)
    }

    func test_ifsg22a_ImpfstatusCZwei_fail() throws {
        // GIVEN
        let token = CBORWebToken
            .mockVaccinationCertificate
            .doseNumber(2)
            .seriesOfDoses(3)
            .medicalProduct(.biontech)
        // WHEN
        let validationResult = try? sut.validate(type: .ifsg22a,
                                                 countryCode: "DE",
                                                 validationClock: Date(),
                                                 certificate: token)
        // THEN
        XCTAssertTrue(true)
        #warning("TODO: enable after rules arrived in Production")
//        XCTAssertEqual(validationResult?.passedResults.count, 0)
//        XCTAssertEqual(validationResult?.failedResults.count, 3)
//        XCTAssertEqual(validationResult?.openResults.count, 0)
    }

    func test_ifsg22a_ImpfstatusBZwei_pass() throws {
        // GIVEN
        let token = CBORWebToken
            .mockVaccinationCertificate
            .doseNumber(3)
            .seriesOfDoses(3)
            .medicalProduct(.biontech)
            .extended()
        let token2 = CBORWebToken.mockRecoveryCertificate.extended()

        let joinedTokens = try XCTUnwrap([token, token2].joinedTokens)
        // WHEN
        let validationResult = try? sut.validate(type: .ifsg22a,
                                                 countryCode: "DE",
                                                 validationClock: Date(),
                                                 certificate: joinedTokens)
        // THEN
        XCTAssertTrue(true)
        #warning("TODO: enable after rules arrived in Production")
//        XCTAssertEqual(validationResult?.passedResults.count, 1)
//        XCTAssertEqual(validationResult?.passedResults.first!.rule!.type, "ImpfstatusBZwei")
//        XCTAssertEqual(validationResult?.failedResults.count, 2)
//        XCTAssertEqual(validationResult?.openResults.count, 0)
    }

    func test_ifsg22a_ImpfstatusEZwei_pass() throws {
        // GIVEN
        let token = CBORWebToken
            .mockVaccinationCertificate
            .doseNumber(2)
            .seriesOfDoses(3)
            .medicalProduct(.biontech)
            .extended()
        let token2 = CBORWebToken.mockRecoveryCertificate.extended()

        let joinedTokens = try XCTUnwrap([token, token2].joinedTokens)

        // WHEN
        let validationResult = try? sut.validate(type: .ifsg22a,
                                                 countryCode: "DE",
                                                 validationClock: Date(),
                                                 certificate: joinedTokens)
        // THEN
        XCTAssertTrue(true)
        #warning("TODO: enable after rules arrived in Production")
//        XCTAssertEqual(validationResult?.passedResults.count, 1)
//        print(validationResult!.passedResults.first!.rule!.type)
//        XCTAssertEqual(validationResult?.passedResults.first!.rule!.type, "ImpfstatusEZwei")
//        XCTAssertEqual(validationResult?.failedResults.count, 2)
//        XCTAssertEqual(validationResult?.openResults.count, 0)
    }

    func test_ifsg22a_ImpfstatusEZwei_fail() throws {
        // GIVEN
        let token = CBORWebToken
            .mockVaccinationCertificate
            .doseNumber(2)
            .seriesOfDoses(3)
            .medicalProduct(.biontech)
            .extended()
        let token2 = CBORWebToken.mockRecoveryCertificate.mockRecovery(fr: Date() - 10).extended()

        let joinedTokens = try XCTUnwrap([token, token2].joinedTokens)

        // WHEN
        let validationResult = try? sut.validate(type: .ifsg22a,
                                                 countryCode: "DE",
                                                 validationClock: Date(),
                                                 certificate: joinedTokens)
        // THEN
        XCTAssertTrue(true)
        #warning("TODO: enable after rules arrived in Production")
//        XCTAssertEqual(validationResult?.passedResults.count, 0)
//        XCTAssertEqual(validationResult?.failedResults.count, 3)
//        XCTAssertEqual(validationResult?.openResults.count, 0)
    }
}
