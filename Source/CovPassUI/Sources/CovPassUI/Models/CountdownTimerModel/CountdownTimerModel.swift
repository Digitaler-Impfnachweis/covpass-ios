//
//  CountdownTimerModel.swift
//
//
//  Created by Thomas Kuleßa on 25.07.22.
//

import Foundation

private enum Constants {
    enum Texts {
        static let countdown = "result_countdown".localized(bundle: .main)
    }
}

open class CountdownTimerModel {
    private let dismissAfterSeconds: TimeInterval
    private let countdownDuration: TimeInterval
    private var countdownDate: TimeInterval?
    private var countdownTimer: Timer?
    public var onUpdate: ((CountdownTimerModel) -> Void)?

    open private(set) var counterInfo: String = "" {
        didSet {
            onUpdate?(self)
        }
    }

    open private(set) var shouldDismiss: Bool = false {
        didSet {
            onUpdate?(self)
        }
    }

    open private(set) var hideCountdown: Bool = true {
        didSet {
            onUpdate?(self)
        }
    }

    public init(dismissAfterSeconds: TimeInterval, countdownDuration: TimeInterval) {
        self.dismissAfterSeconds = dismissAfterSeconds
        self.countdownDuration = countdownDuration
    }

    deinit {
        resetTimer()
    }

    open func reset() {
        resetTimer()
        counterInfo = ""
        shouldDismiss = false
        hideCountdown = true
    }

    open func start() {
        guard countdownTimer == nil else { return }
        countdownDate = Date().timeIntervalSinceReferenceDate + dismissAfterSeconds
        countdownTimer = Timer.scheduledTimer(
            withTimeInterval: 1,
            repeats: true,
            block: { [weak self] timer in
                self?.countdown(timer: timer)
            }
        )
    }

    private func resetTimer() {
        countdownTimer?.invalidate()
        countdownTimer = nil
        countdownDate = nil
    }

    private func countdown(timer _: Timer) {
        guard let countdownDate = countdownDate else { return }
        let now = Date().timeIntervalSinceReferenceDate
        let secondsLeft = countdownDate - now

        if secondsLeft <= 0 {
            shouldDismiss = true
            resetTimer()
        } else if secondsLeft <= countdownDuration {
            counterInfo = .init(
                format: Constants.Texts.countdown,
                Int(secondsLeft)
            )
            hideCountdown = false
        }
    }
}
