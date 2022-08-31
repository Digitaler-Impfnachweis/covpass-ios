//
//  AcousticFeedbackSettingsViewModelProtocol.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

protocol AcousticFeedbackSettingsViewModelProtocol {
    var header: String { get }
    var description: String { get }
    var switchLabel: String { get }
    var enableAcousticFeedback: Bool { get set }
}
