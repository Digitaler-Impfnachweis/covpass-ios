//
//  CheckAppUpdateTests.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import PromiseKit
import XCTest

@testable import CovPassCommon

class CheckAppUpdateServiceMock: CheckAppUpdateServiceProtocol {
    var versionResult: Promise<String>?
    func getAppStoreVersion() -> Promise<String> {
        versionResult ?? Promise.value("")
    }
}

class CheckAppUpdateTests: XCTestCase {
    func testAppUpdate() throws {
        let service = CheckAppUpdateServiceMock()
        service.versionResult = Promise.value("1.0.1")
        let userDefaults = MockPersistence()
        var sut = CheckAppUpdate(service: service, userDefaults: userDefaults, appStoreID: "1")
        sut.bundleVersion = "1.0.0"

        let appUpdate = try sut.updateAvailable().wait()
        XCTAssert(appUpdate.shouldUpdate)
        XCTAssertEqual(appUpdate.version, "1.0.1")
    }

    func testAppUpdateNothingNew() throws {
        let service = CheckAppUpdateServiceMock()
        service.versionResult = Promise.value("1.0.0")
        let userDefaults = MockPersistence()
        var sut = CheckAppUpdate(service: service, userDefaults: userDefaults, appStoreID: "1")
        sut.bundleVersion = "1.0.0"

        let appUpdate = try sut.updateAvailable().wait()
        XCTAssertFalse(appUpdate.shouldUpdate)
    }

    func testAppUpdateAlreadyConfirmed() {
        do {
            let service = CheckAppUpdateServiceMock()
            service.versionResult = Promise.value("1.0.1")
            let userDefaults = MockPersistence()
            try userDefaults.store(UserDefaults.keyCheckVersionUpdate, value: "1.0.0")
            var sut = CheckAppUpdate(service: service, userDefaults: userDefaults, appStoreID: "1")
            sut.bundleVersion = "1.0.0"

            _ = try sut.updateAvailable().wait()
            XCTFail("Should fail")
        } catch {
            XCTAssert(type(of: error) == PromiseCancelledError.self)
        }
    }

    func testAppUpdateFullFlow() throws {
        // New Update avilable
        let service = CheckAppUpdateServiceMock()
        service.versionResult = Promise.value("1.0.1")
        let userDefaults = MockPersistence()
        var sut = CheckAppUpdate(service: service, userDefaults: userDefaults, appStoreID: "1")
        sut.bundleVersion = "1.0.0"

        var appUpdate = try sut.updateAvailable().wait()
        XCTAssert(appUpdate.shouldUpdate)
        XCTAssertEqual(appUpdate.version, "1.0.1")

        // Update App
        sut.bundleVersion = "1.0.1"

        // Everything is up to date
        appUpdate = try sut.updateAvailable().wait()
        XCTAssertFalse(appUpdate.shouldUpdate)

        // New app version in store
        service.versionResult = Promise.value("1.1")

        // App update is available
        appUpdate = try sut.updateAvailable().wait()
        XCTAssert(appUpdate.shouldUpdate)
        XCTAssertEqual(appUpdate.version, "1.1")

        // User declines dialog for 1.1
        try userDefaults.store(UserDefaults.keyCheckVersionUpdate, value: "1.0.1")

        // No dialog because user declined previous one
        do {
            _ = try sut.updateAvailable().wait()
            XCTFail("Should fail")
        } catch {
            XCTAssert(type(of: error) == PromiseCancelledError.self)
        }

        // New app version in store
        service.versionResult = Promise.value("1.2")

        // Still no dialog because user declined previous one
        do {
            _ = try sut.updateAvailable().wait()
            XCTFail("Should fail")
        } catch {
            XCTAssert(type(of: error) == PromiseCancelledError.self)
        }

        // Update App
        sut.bundleVersion = "1.2"

        // Everything is up to date
        appUpdate = try sut.updateAvailable().wait()
        XCTAssertFalse(appUpdate.shouldUpdate)

        // New app version in store
        service.versionResult = Promise.value("1.3")

        // Now a new app update is available and the dialog is displayed
        appUpdate = try sut.updateAvailable().wait()
        XCTAssert(appUpdate.shouldUpdate)
        XCTAssertEqual(appUpdate.version, "1.3")
    }
}
