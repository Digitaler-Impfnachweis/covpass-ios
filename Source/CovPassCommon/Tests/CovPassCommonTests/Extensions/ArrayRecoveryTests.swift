//
//  ArrayRecoveryTests.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassCommon
import Foundation
import XCTest

class ArrayRecoveryTests: XCTestCase {
    func testFetchLatesRecovery() throws {
        let recovery2020 = Recovery(tg: "",
                                    fr: try XCTUnwrap(DateUtils.isoDateFormatter.date(from: "2020-01-10")),
                                    df: Date(),
                                    du: Date(),
                                    co: "",
                                    is: "",
                                    ci: "1")
        let recovery2021 = Recovery(tg: "",
                                    fr: try XCTUnwrap(DateUtils.isoDateFormatter.date(from: "2021-01-10")),
                                    df: Date(),
                                    du: Date(),
                                    co: "",
                                    is: "",
                                    ci: "2")
        let recovery2022 = Recovery(tg: "",
                                    fr: try XCTUnwrap(DateUtils.isoDateFormatter.date(from: "2022-01-10")),
                                    df: Date(),
                                    du: Date(),
                                    co: "",
                                    is: "",
                                    ci: "3")

        let recoveries = [recovery2020, recovery2022, recovery2021]

        XCTAssertEqual(recoveries.latestRecovery?.ci, recovery2022.ci)
    }
}
