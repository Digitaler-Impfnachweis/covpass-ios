//
//  ImprintViewModelProtocol.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation

protocol ImprintViewModelProtocol {
    var title: String { get }
    var subtitle: String { get }
    var publisher: String { get }
    var address: String { get }
    var contactTitle: String { get }
    var contactMail: String { get }
    var contactForm: String { get }
    var vatNumberTitle: String { get }
    var vatNumber: String { get }
}
