//
//  CountdownViewModelProtocol.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation

public protocol CountdownViewModel {
    var countdownTimerModel: CountdownTimerModel { get }
    func startCountdown()
    func stopCountdown()
}

public extension CountdownViewModel {
    func startCountdown() {
        countdownTimerModel.start()
    }

    func stopCountdown() {
        countdownTimerModel.reset()
    }
}
