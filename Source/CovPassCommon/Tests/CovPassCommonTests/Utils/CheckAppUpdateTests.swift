//
//  CheckAppUpdateTests.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import XCTest
import PromiseKit

@testable import CovPassCommon

struct CheckAppUpdateServiceMock: CheckAppUpdateServiceProtocol {
    var versionResult: Promise<String>?
    func getAppStoreVersion() -> Promise<String> {
        return versionResult ?? Promise.value("")
    }
}

class CheckAppUpdateTests: XCTestCase {

    func testAppUpdate() throws {
        var service = CheckAppUpdateServiceMock()
        service.versionResult = Promise.value("1.0.1")
        let userDefaults = MockPersistence()
        var sut = CheckAppUpdate(service, userDefaults)
        sut.bundleVersion = "1.0.0"

        let appUpdate = try sut.updateAvailable().wait()
        XCTAssert(appUpdate.shouldUpdate)
        XCTAssertEqual(appUpdate.version, "1.0.1")
    }

    func testAppUpdateNothingNew() throws {
        var service = CheckAppUpdateServiceMock()
        service.versionResult = Promise.value("1.0.0")
        let userDefaults = MockPersistence()
        var sut = CheckAppUpdate(service, userDefaults)
        sut.bundleVersion = "1.0.0"

        let appUpdate = try sut.updateAvailable().wait()
        XCTAssertFalse(appUpdate.shouldUpdate)
    }

    func testAppUpdateAlreadyConfirmed() {
        do {
            var service = CheckAppUpdateServiceMock()
            service.versionResult = Promise.value("1.0.1")
            let userDefaults = MockPersistence()
            try userDefaults.store(UserDefaults.keyCheckVersionUpdate, value: "1.0.0")
            var sut = CheckAppUpdate(service, userDefaults)
            sut.bundleVersion = "1.0.0"

            _ = try sut.updateAvailable().wait()
            XCTFail("Should fail")
        } catch {
            XCTAssert(type(of: error) == PromiseCancelledError.self)
        }
    }
}
