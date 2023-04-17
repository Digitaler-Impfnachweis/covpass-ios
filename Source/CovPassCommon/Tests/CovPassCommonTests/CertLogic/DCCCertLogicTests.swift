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
    var sut: DCCCertLogic!
    var repository: VaccinationRepositoryProtocol!
    let jsonDecoder = JSONDecoder()

    override func setUp() {
        super.setUp()
        keychain = MockPersistence()
        userDefaults = MockPersistence()
        sut = DCCCertLogic(initialDCCBNRulesURL: Bundle.commonBundle.url(forResource: "dcc-bn-rules", withExtension: "json")!,
                           initialDomesticDCCRulesURL: Bundle.commonBundle.url(forResource: "dcc-domestic-rules", withExtension: "json")!,
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
        XCTAssertEqual(sut.valueSets["covid-19-lab-test-manufacturer-and-name"]?.count, 299)
        XCTAssertEqual(sut.valueSets["covid-19-lab-test-type"]?.count, 2)
        XCTAssertEqual(sut.valueSets["disease-agent-targeted"]?.count, 1)
        XCTAssertEqual(sut.valueSets["sct-vaccines-covid-19"]?.count, 9)
        XCTAssertEqual(sut.valueSets["vaccines-covid-19-auth-holders"]?.count, 30)
        XCTAssertEqual(sut.valueSets["vaccines-covid-19-names"]?.count, 38)
    }

    func testRemoteValueSets() throws {
        let data = try JSONEncoder().encode([ValueSet(id: "valueSet", hash: "1", data: Data())])
        userDefaults.valueSets = data

        XCTAssertEqual(sut.valueSets.count, 1)
        XCTAssertEqual(sut.valueSets["valueSet"]?.count, 0)
    }

    func test_rulesAvailable_ifsg22a() {
        // WHEN
        let rulesAvailable = sut.rulesAvailable(logicType: .ifsg22a, region: nil)
        // THEN
        XCTAssertTrue(rulesAvailable)
    }
}
