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
        XCTAssertEqual(sut.valueSets["covid-19-lab-test-manufacturer-and-name"]?.count, 227)
        XCTAssertEqual(sut.valueSets["covid-19-lab-test-type"]?.count, 2)
        XCTAssertEqual(sut.valueSets["disease-agent-targeted"]?.count, 1)
        XCTAssertEqual(sut.valueSets["sct-vaccines-covid-19"]?.count, 6)
        XCTAssertEqual(sut.valueSets["vaccines-covid-19-auth-holders"]?.count, 29)
        XCTAssertEqual(sut.valueSets["vaccines-covid-19-names"]?.count, 34)
    }

    func testRemoteValueSets() throws {
        let data = try JSONEncoder().encode([ValueSet(id: "valueSet", hash: "1", data: Data())])
        userDefaults.valueSets = data

        XCTAssertEqual(sut.valueSets.count, 1)
        XCTAssertEqual(sut.valueSets["valueSet"]?.count, 0)
    }
    
    func testUpdateRulesIfNeededTrue() throws {
        let dateDefault = Date().addingTimeInterval(-100000000)
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


    func testSavedAndLocalRules() throws {
        // Check local rules (no saved rules)
        XCTAssertEqual(sut.dccRules.count, 322)

        // Save one rule
        let rule = Rule(identifier: "", type: "", version: "", schemaVersion: "", engine: "", engineVersion: "", certificateType: "", description: [], validFrom: "", validTo: "", affectedString: [], logic: JSON(""), countryCode: "")
        rule.hash = "1"
        let data = try JSONEncoder().encode([rule])
        try XCTUnwrap(keychain.store(KeychainPersistence.Keys.dccRules.rawValue, value: data))

        // Check saved rules
        XCTAssertEqual(sut.dccRules.count, 1)
    }

    func testValidVaccination() throws {
        let cert = try repository.checkCertificate(CertificateMock.validCertificate2).wait()

        let res = try sut.validate(countryCode: "DE", validationClock: Date(), certificate: cert)

        XCTAssertEqual(res.count, 4)
        XCTAssertEqual(res.failedResults.count, 0)
    }

    func testInvalidVaccination() throws {
        let cert = try repository.checkCertificate(CertificateMock.validCertificate2).wait()
        cert.hcert.dgc.v![0].dt = Date(timeIntervalSince1970: 0)

        let res = try sut.validate(countryCode: "DE", validationClock: Date(), certificate: cert)

        XCTAssertEqual(res.count, 4)
        XCTAssertEqual(res.failedResults.count, 1)
        XCTAssertEqual(res.failedResults.first?.rule?.identifier, "VR-DE-0004")
    }

    func testValidVaccinationWithoutRules() {
        do {
            let sut = DCCCertLogic(initialDCCRulesURL: Bundle.commonBundle.url(forResource: "dsc", withExtension: "json")!,
                                   initialDomesticDCCRulesURL: Bundle.commonBundle.url(forResource: "dcc-domestic-rules", withExtension: "json")!,
                                   service: DCCServiceMock(),
                                   keychain: MockPersistence(),
                                   userDefaults: MockPersistence())
            let cert = try repository.checkCertificate(CertificateMock.validCertificate2).wait()

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

        XCTAssertEqual(res.count, 2)
        XCTAssertEqual(res.failedResults.count, 0)
    }

    func testInvalidRecovery() throws {
        let cert = try repository.checkCertificate(CertificateMock.validRecoveryCertificate).wait()
        cert.hcert.dgc.r![0].fr = Date(timeIntervalSince1970: 0)

        let res = try sut.validate(countryCode: "DE", validationClock: Date(), certificate: cert)

        XCTAssertEqual(res.count, 2)
        XCTAssertEqual(res.failedResults.count, 1)
        XCTAssertEqual(res.failedResults.first?.rule?.identifier, "RR-DE-0002")
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
    
    // MARK: Domestic vs EU Rules
    // Some Background:
    //  RR-DE-0001 Domestic -> older than 28 Days
    //  RR-DE-0001 EU       -> older than 28 Days
    //  RR-DE-0002 Domestic -> The positive NAA test result (e.g., PCR) must be no older than 3 ( 90 days) months.
    //  RR-DE-0002 EU       -> The positive NAA test result (e.g., PCR) must be no older than 6 (180 days) months.
    
    func testDomesticRules181DaysAfterRecovery() {
        // GIVEN
        let now = Date()
        let dateAfter91Days = now.addingTimeInterval(60*60*24*181)
        let token = CBORWebToken.mockRecoveryCertificate.extended()
        token.firstRecovery?.fr = now
        
        // WHEN
        let results = try! sut.validate(type: .de,
                                        countryCode: "DE",
                                        validationClock: dateAfter91Days,
                                        certificate: token.vaccinationCertificate)
        
        // THEN
        XCTAssertEqual(results.count, 2)
        XCTAssertEqual(results.result(ofRule: "RR-DE-0001"), .passed)
    }
    
    func testEURules181DaysAfterRecovery() {
        // GIVEN
        let now = Date()
        let dateAfter91Days = now.addingTimeInterval(60*60*24*181)
        let token = CBORWebToken.mockRecoveryCertificate.extended()
        token.firstRecovery?.fr = now
        
        // WHEN
        let results = try! sut.validate(type: .eu,
                                        countryCode: "DE",
                                        validationClock: dateAfter91Days,
                                        certificate: token.vaccinationCertificate)
        
        // THEN
        XCTAssertEqual(results.count, 2)
        XCTAssertEqual(results.result(ofRule: "RR-DE-0001"), .passed)
        XCTAssertEqual(results.result(ofRule: "RR-DE-0002"), .fail)
    }
    
    func testDomesticRules91DaysAfterRecovery() {
        // GIVEN
        let now = Date()
        let dateAfter91Days = now.addingTimeInterval(60*60*24*91)
        let token = CBORWebToken.mockRecoveryCertificate.extended()
        token.firstRecovery?.fr = now
        
        // WHEN
        let results = try! sut.validate(type: .de,
                                        countryCode: "DE",
                                        validationClock: dateAfter91Days,
                                        certificate: token.vaccinationCertificate)
        
        // THEN
        XCTAssertEqual(results.count, 2)
        XCTAssertEqual(results.result(ofRule: "RR-DE-0001"), .passed)
    }
    
    func testEURules89DaysAfterRecovery() {
        // GIVEN
        let now = Date()
        let dateAfter89Days = now.addingTimeInterval(60*60*24*89)
        let token = CBORWebToken.mockRecoveryCertificate.extended()
        token.firstRecovery?.fr = now
        
        // WHEN
        let results = try! sut.validate(type: .eu,
                                        countryCode: "DE",
                                        validationClock: dateAfter89Days,
                                        certificate: token.vaccinationCertificate)
        
        // THEN
        XCTAssertEqual(results.count, 2)
        XCTAssertEqual(results.result(ofRule: "RR-DE-0001"), .passed)
        XCTAssertEqual(results.result(ofRule: "RR-DE-0002"), .passed)
    }
    
    func testDomesticRules29DaysAfterRecovery() {
        // GIVEN
        let now = Date()
        let dateAfter29Days = now.addingTimeInterval(60*60*24*29)
        let token = CBORWebToken.mockRecoveryCertificate.extended()
        token.firstRecovery?.fr = now
        
        // WHEN
        let results = try! sut.validate(type: .de,
                                        countryCode: "DE",
                                        validationClock: dateAfter29Days,
                                        certificate: token.vaccinationCertificate)
        
        // THEN
        XCTAssertEqual(results.count, 2)
        XCTAssertEqual(results.result(ofRule: "RR-DE-0001"), .passed)
    }
    
    func testEURules29DaysAfterRecovery() {
        // GIVEN
        let now = Date()
        let dateAfter29Days = now.addingTimeInterval(60*60*24*29)
        let token = CBORWebToken.mockRecoveryCertificate.extended()
        token.firstRecovery?.fr = now
        
        // WHEN
        let results = try! sut.validate(type: .eu,
                                        countryCode: "DE",
                                        validationClock: dateAfter29Days,
                                        certificate: token.vaccinationCertificate)
        
        // THEN
        XCTAssertEqual(results.count, 2)
        XCTAssertEqual(results.result(ofRule: "RR-DE-0001"), .passed)
        XCTAssertEqual(results.result(ofRule: "RR-DE-0002"), .passed)
    }
    
    func testDomesticRules2DaysAfterRecovery() {
        // GIVEN
        let now = Date()
        let dateAfter2Days = now.addingTimeInterval(60*60*24*2)
        let token = CBORWebToken.mockRecoveryCertificate.extended()
        token.firstRecovery?.fr = now
        
        // WHEN
        let results = try! sut.validate(type: .de,
                                        countryCode: "DE",
                                        validationClock: dateAfter2Days,
                                        certificate: token.vaccinationCertificate)
        
        // THEN
        XCTAssertEqual(results.count, 2)
        XCTAssertEqual(results.result(ofRule: "RR-DE-0001"), .fail)
    }
    
    func testEURules2DaysAfterRecovery() {
        // GIVEN
        let now = Date()
        let dateAfter2Days = now.addingTimeInterval(60*60*24*2)
        let token = CBORWebToken.mockRecoveryCertificate.extended()
        token.firstRecovery?.fr = now
        
        // WHEN
        let results = try! sut.validate(type: .eu,
                                        countryCode: "DE",
                                        validationClock: dateAfter2Days,
                                        certificate: token.vaccinationCertificate)
        
        // THEN
        XCTAssertEqual(results.count, 2)
        XCTAssertEqual(results.result(ofRule: "RR-DE-0001"), .fail)
        XCTAssertEqual(results.result(ofRule: "RR-DE-0002"), .passed)
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
    
    func testBoosterRulesShouldUpdate() {
        let exp = expectation(description: "Booster Rules should update")
        // GIVEN
        userDefaults.lastUpdatedBoosterRules = Date().addingTimeInterval(60*60*24 * (-1))
        // WHEN
        sut.boosterRulesShouldBeUpdated()
            .done{
                // THEN
                if $0 {
                    exp.fulfill()
                } else {
                    XCTFail()
                }
            }.cauterize()
        wait(for: [exp], timeout: 0.1)
    }
    
    func testBoosterRulesShoulNotdUpdate() {
        let exp = expectation(description: "Booster Rules should not update")
        // GIVEN
        userDefaults.lastUpdatedBoosterRules = Date()
        // WHEN
        sut.boosterRulesShouldBeUpdated()
            .done{
                if !$0 {
                    // THEN
                    exp.fulfill()
                }
            }.cauterize()
        wait(for: [exp], timeout: 0.1, enforceOrder: true)
    }
    
    func testUpdateBoosterRuleIfNeeded() {
        let exp = expectation(description: "Update If Needed")
        // GIVEN
        userDefaults.lastUpdatedBoosterRules = Date()
        // WHEN
        sut.updateBoosterRulesIfNeeded()
            .done{
                // THEN
                exp.fulfill()
            }.cauterize()
        wait(for: [exp], timeout: 0.1, enforceOrder: true)
    }
    
    func testValueSetsShouldUpdate() {
        let exp = expectation(description: "Booster Rules should update")
        // GIVEN
        userDefaults.lastUpdatedValueSets = Date().addingTimeInterval(60*60*24 * (-1))
        // WHEN
        sut.valueSetsShouldBeUpdated()
            .done{
                if $0 {
                    // THEN
                    exp.fulfill()
                }
            }.cauterize()
        wait(for: [exp], timeout: 0.1, enforceOrder: true)
    }
    
    func testValueSetsShoulNotdUpdate() {
        let exp = expectation(description: "Booster Rules should not update")
        // GIVEN
        userDefaults.lastUpdatedValueSets = Date()
        // WHEN
        sut.valueSetsShouldBeUpdated()
            .done{
                if !$0 {
                    // THEN
                    exp.fulfill()
                }
            }.cauterize()
        wait(for: [exp], timeout: 0.1, enforceOrder: true)
    }
    
    func testUpdateValueSetIfNeeded() {
        let exp = expectation(description: "Update If Needed")
        // GIVEN
        userDefaults.lastUpdatedValueSets = Date()
        // WHEN
        sut.updateValueSetsIfNeeded()
            .done{
                // THEN
                exp.fulfill()
            }.cauterize()
        wait(for: [exp], timeout: 0.1, enforceOrder: true)
    }
}
