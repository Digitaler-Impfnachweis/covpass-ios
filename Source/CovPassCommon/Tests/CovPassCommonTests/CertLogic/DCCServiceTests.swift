//
//  DCCServiceTests.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CertLogic
@testable import CovPassCommon
import Foundation
import PromiseKit
import XCTest

class DCCServiceTests: XCTestCase {
    var sut: DCCService!
    var sessionMock: CustomURLSessionMock!

    override func setUp() {
        super.setUp()
        sessionMock = CustomURLSessionMock()
        sut = DCCService(url: URL(string: "https://digitaler-impfnachweis-app.de")!,
                         boosterURL: URL(string: "https://digitaler-impfnachweis-app.de")!,
                         domesticURL: URL(string: "https://digitaler-impfnachweis-app.de")!,
                         customURLSession: sessionMock)
    }

    override func tearDown() {
        sut = nil
        sessionMock = nil
        super.tearDown()
    }

    func testErrorCode() {
        XCTAssertEqual(DCCServiceError.requestCancelled.errorCode, 101)
        XCTAssertEqual(DCCServiceError.invalidURL.errorCode, 103)
        XCTAssertEqual(DCCServiceError.invalidResponse.errorCode, 104)
    }

    func testloadDCCRules() throws {
        sessionMock.requestResponse = Promise.value(try XCTUnwrap(String(data: try JSONEncoder().encode([RuleSimple.mock]), encoding: .utf8)))
        let res = try sut.loadDCCRules().wait()
        XCTAssertEqual(res.count, 1)
    }

    func testloadDCCRulesFails() throws {
        sessionMock.requestResponse = Promise(error: APIError.invalidResponse)
        do {
            _ = try sut.loadDCCRules().wait()
            XCTFail("Should fail")
        } catch {
            XCTAssertEqual(error.localizedDescription, APIError.invalidResponse.localizedDescription)
        }
    }

    func testLoadDCCRule() throws {
        sessionMock.requestResponse = Promise.value(try XCTUnwrap(String(data: try JSONEncoder().encode(Rule.mock), encoding: .utf8)))
        let res = try sut.loadDCCRule(country: "foo", hash: "bar").wait()
        XCTAssertEqual(res.identifier, "rule-identifier")
        XCTAssertEqual(res.hash, "bar")
    }

    func testLoadDCCRuleFails() throws {
        sessionMock.requestResponse = Promise(error: APIError.invalidResponse)
        do {
            _ = try sut.loadDCCRule(country: "foo", hash: "bar").wait()
            XCTFail("Should fail")
        } catch {
            XCTAssertEqual(error.localizedDescription, APIError.invalidResponse.localizedDescription)
        }
    }

    func testLoadValueSets() throws {
        sessionMock.requestResponse = Promise.value(try XCTUnwrap(String(data: try JSONEncoder().encode([["foo": "bar"]]), encoding: .utf8)))
        let res = try sut.loadValueSets().wait()
        XCTAssertEqual(res, [["foo": "bar"]])
    }

    func testLoadValueSetsFails() throws {
        sessionMock.requestResponse = Promise(error: APIError.invalidResponse)
        do {
            _ = try sut.loadValueSets().wait()
            XCTFail("Should fail")
        } catch {
            XCTAssertEqual(error.localizedDescription, APIError.invalidResponse.localizedDescription)
        }
    }

    func testLoadValueSet() throws {
        sessionMock.requestResponse = Promise.value(try XCTUnwrap(String(data: try JSONEncoder().encode(CovPassCommon.ValueSet(id: "foo", hash: "bar", data: Data())), encoding: .utf8)))
        let res = try sut.loadValueSet(id: "foo", hash: "bar").wait()
        XCTAssertEqual(res.id, "foo")
    }

    func testLoadValueSetsFail() throws {
        sessionMock.requestResponse = Promise(error: APIError.invalidResponse)
        do {
            _ = try sut.loadValueSet(id: "foo", hash: "bar").wait()
            XCTFail("Should fail")
        } catch {
            XCTAssertEqual(error.localizedDescription, APIError.invalidResponse.localizedDescription)
        }
    }

    func testLoadBoosterRules() throws {
        sessionMock.requestResponse = Promise.value(try XCTUnwrap(String(data: try JSONEncoder().encode([RuleSimple.mock]), encoding: .utf8)))
        let res = try sut.loadBoosterRules().wait()
        XCTAssertEqual(res.count, 1)
    }

    func testLoadDomesticRules() throws {
        // GIVEN
        sessionMock.requestResponse = Promise.value(try XCTUnwrap(String(data: try JSONEncoder().encode([RuleSimple.mock]), encoding: .utf8)))
        // WHEN
        let res = try sut.loadDomesticRules().wait()
        // THEN
        XCTAssertEqual(res.count, 1)
    }

    func testLoadDomesticRulesInvalidResponse() throws {
        // GIVEN
        sessionMock.requestResponse = Promise.value(try XCTUnwrap("FOO"))
        do {
            // WHEN
            _ = try sut.loadDomesticRules().wait()
            XCTFail("Should fail")
        } catch {
            // THEN
            XCTAssertEqual(error.localizedDescription, DCCServiceError.invalidResponse.localizedDescription)
        }
    }

    func testLoadBoosterRulesFails() throws {
        sessionMock.requestResponse = Promise(error: APIError.invalidResponse)
        do {
            _ = try sut.loadBoosterRules().wait()
            XCTFail("Should fail")
        } catch {
            XCTAssertEqual(error.localizedDescription, APIError.invalidResponse.localizedDescription)
        }
    }

    func testLoadBoosterRule() throws {
        sessionMock.requestResponse = Promise.value(try XCTUnwrap(String(data: try JSONEncoder().encode(Rule.mock), encoding: .utf8)))
        let res = try sut.loadBoosterRule(hash: "foo").wait()
        XCTAssertEqual(res.identifier, "rule-identifier")
    }

    func testLoadDomesticRule() throws {
        // GIVEN
        sessionMock.requestResponse = Promise.value(try XCTUnwrap(String(data: try JSONEncoder().encode(Rule.mock), encoding: .utf8)))
        // WHEN
        let res = try sut.loadDomesticRule(hash: "foo").wait()
        // THEN
        XCTAssertEqual(res.identifier, "rule-identifier")
    }

    func testLoadDomesticRuleInvalidResponse() throws {
        // GIVEN
        sessionMock.requestResponse = Promise.value(try XCTUnwrap(String("FOO")))
        do {
            // WHEN
            _ = try sut.loadDomesticRule(hash: "foo").wait()
            XCTFail("Should fail")
        } catch {
            // THEN
            XCTAssertEqual(error.localizedDescription, DCCServiceError.invalidResponse.localizedDescription)
        }
    }

    func testLoadBoosterRulesFail() throws {
        sessionMock.requestResponse = Promise(error: APIError.invalidResponse)
        do {
            _ = try sut.loadBoosterRule(hash: "foo").wait()
            XCTFail("Should fail")
        } catch {
            XCTAssertEqual(error.localizedDescription, APIError.invalidResponse.localizedDescription)
        }
    }
}
