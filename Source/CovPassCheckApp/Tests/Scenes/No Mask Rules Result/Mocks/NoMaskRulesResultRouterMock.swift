//
//  NoMaskRulesResultRouterMock.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassCheckApp
import XCTest

final class NoMaskRulesResultRouterMock: NoMaskRulesResultRouterProtocol {
    let rescanExpectation = XCTestExpectation(description: "rescanExpectation")
    func rescan() {
        rescanExpectation.fulfill()
    }
}
