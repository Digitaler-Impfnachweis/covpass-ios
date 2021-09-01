//
//  BoosterNotificationTests.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import XCTest
import CovPassCommon
@testable import CovPassApp

class BoosterNotificationTests: XCTestCase {

    func testNotificationFlag() throws {
        let userDefaults = try XCTUnwrap(UserDefaults(suiteName: "NotificationSettings"))

        var certificate = try ExtendedCBORWebToken.mock()

        XCTAssertNil(userDefaults.value(forKey: certificate.identifier))
        XCTAssertFalse(certificate.hasNotifications)

        certificate.hasNotifications = true
        XCTAssertTrue(certificate.hasNotifications)
        XCTAssertTrue(userDefaults.bool(forKey: certificate.identifier))

        certificate.hasNotifications = false
        XCTAssertNil(userDefaults.value(forKey: certificate.identifier))
        XCTAssertFalse(certificate.hasNotifications)
    }

}

extension ExtendedCBORWebToken {
    // 1:1 copy of the 'live' code to review handling in `UserDefaults` without exposing this property
    fileprivate var identifier: String {
        let name = vaccinationCertificate.hcert.dgc.nam.fullNameTransliterated
        let dob = vaccinationCertificate.hcert.dgc.dobString ?? ""
        return CustomHasher.sha256("\(name)\(dob)")
    }
}
