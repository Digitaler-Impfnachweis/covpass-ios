//
//  KeychainPersistence.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation

public extension KeychainPersistence {
    enum Keys: String, CaseIterable {
        case certificateList = "VaccinationCertificateList"
        case trustList = "TrustList"
        case dccRules = "DCCRules"
        case boosterRules = "BooterRules"
    }
    static let certificateListKey = "VaccinationCertificateList"
    static let trustListKey = "TrustList"
    static let dccRulesKey = "DCCRules"
    static let boosterRulesKey = "BooterRules"
}
