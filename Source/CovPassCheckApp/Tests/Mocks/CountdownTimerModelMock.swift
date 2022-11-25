//
//  CountdownTimerModelMock.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassUI
import Foundation
import XCTest

class CountdownTimerModelMock: CountdownTimerModel {
    let resetExpectation = XCTestExpectation()

    override var hideCountdown: Bool {
        get {
            mockedHideCountdown
        }
        set {
            mockedHideCountdown = newValue
        }
    }

    override var counterInfo: String {
        get {
            mockedCounterInfo
        }
        set {
            mockedCounterInfo = newValue
        }
    }

    override func reset() {
        super.reset()
        resetExpectation.fulfill()
    }

    override init(dismissAfterSeconds: TimeInterval, countdownDuration: TimeInterval) {
        super.init(dismissAfterSeconds: dismissAfterSeconds, countdownDuration: countdownDuration)
    }

    init() {
        super.init(dismissAfterSeconds: .greatestFiniteMagnitude, countdownDuration: 0)
    }

    var mockedHideCountdown = false
    var mockedCounterInfo = "This view closes in 7 seconds."
}
