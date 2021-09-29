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
}
