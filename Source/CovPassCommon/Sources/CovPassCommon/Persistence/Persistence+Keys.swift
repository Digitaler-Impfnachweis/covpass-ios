//
//  Persistence+Keys.swift
//  
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation

public extension Persistence {
    var announcementVersion: String? {
        get {
            let value = try? fetch(UserDefaults.keyAnnouncement) as? String
            return value
        }
        set {
            try? store(UserDefaults.keyAnnouncement, value: newValue as Any)
        }
    }

    var privacyHash: String? {
        get {
            let value = try? fetch(UserDefaults.keyPrivacy) as? String
            return value
        }
        set {
            try? store(UserDefaults.keyPrivacy, value: newValue as Any)
        }
    }

    var privacyShownForAppVersion: String? {
        get {
            let value = try? fetch(UserDefaults.keyPrivacyShownForAppVersion) as? String
            return value
        }
        set {
            try? store(UserDefaults.keyPrivacyShownForAppVersion, value: newValue as Any)
        }
    }

    var revocationExpertMode: Bool {
        get {
            let value = try? fetch(UserDefaults.keyRevocationExpertMode) as? Bool
            return value ?? false
        }
        set {
            try? store(UserDefaults.keyRevocationExpertMode, value: newValue as Any)
        }
    }

    var onboardingSelectedLogicTypeAlreadySeen: Bool? {
        get {
            let value = try? fetch(UserDefaults.keyOnboardingSelectedLogicTypeAlreadySeen) as? Bool
            return value
        }
        set {
            try? store(UserDefaults.keyOnboardingSelectedLogicTypeAlreadySeen, value: newValue as Any)
        }
    }

    var lastUpdatedBoosterRules: Date? {
        get {
            let value = try? fetch(UserDefaults.keyLastUpdatedBoosterRules) as? Date
            return value
        }
        set {
            try? store(UserDefaults.keyLastUpdatedBoosterRules, value: newValue as Any)
        }
    }

    var lastUpdatedValueSets: Date? {
        get {
            let value = try? fetch(UserDefaults.keyLastUpdatedValueSets) as? Date
            return value
        }
        set {
            try? store(UserDefaults.keyLastUpdatedValueSets, value: newValue as Any)
        }
    }
    
    var lastUpdatedDCCRules: Date? {
        get {
            let value = try? fetch(UserDefaults.keyLastUpdatedDCCRules) as? Date
            return value
        }
        set {
            try? store(UserDefaults.keyLastUpdatedDCCRules, value: newValue as Any)
        }
    }
    
    var lastUpdateDomesticRules: Date? {
        get {
            let value = try? fetch(UserDefaults.keyLastUpdateDomesticRuless) as? Date
            return value
        }
        set {
            try? store(UserDefaults.keyLastUpdateDomesticRuless, value: newValue as Any)
        }
    }

    var lastUpdatedTrustList: Date? {
        get {
            let value = try? fetch(UserDefaults.keyLastUpdatedTrustList) as? Date
            return value
        }
        set {
            try? store(UserDefaults.keyLastUpdatedTrustList, value: newValue as Any)
        }
    }

    var lastQueriedRevocation: Date? {
        get {
            let value = try? fetch(UserDefaults.keyLastQueriedRevocation) as? Date
            return value
        }
        set {
            try? store(UserDefaults.keyLastQueriedRevocation, value: newValue as Any)
        }
    }

    var valueSets: Data? {
        get {
            let value = try? fetch(UserDefaults.keyValueSets) as? Data
            return value
        }
        set {
            try? store(UserDefaults.keyValueSets, value: newValue as Any)
        }
    }

    var trustList: Data? {
        get {
            let value = try? fetch(KeychainPersistence.Keys.trustList.rawValue) as? Data
            return value
        }
        set {
            try? store(KeychainPersistence.Keys.trustList.rawValue, value: newValue as Any)
        }
    }
}

