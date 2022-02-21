//
//  UserDefaultsPersistence.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation

public struct UserDefaultsPersistence: Persistence {
    public init() {}

    public func store(_ key: String, value: Any) throws {
        UserDefaults.standard.setValue(value, forKey: key)
    }

    public func fetch(_ key: String) throws -> Any? {
        UserDefaults.standard.object(forKey: key)
    }

    public func delete(_ key: String) throws {
        UserDefaults.standard.removeObject(forKey: key)
    }

    public func deleteAll() throws {}
}

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
    
    var selectedLogicType: DCCCertLogic.LogicType {
        get {
            let value = try? fetch(UserDefaults.keySelectedLogicType) as? String
            let valueLogicType = DCCCertLogic.LogicType(rawValue: value ?? "")
            return valueLogicType ?? .de
        }
        set {
            try? store(UserDefaults.keySelectedLogicType, value: newValue.rawValue as Any)
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
    
    var lastUpdatedTrustList: Date? {
        get {
            let value = try? fetch(UserDefaults.keyLastUpdatedTrustList) as? Date
            return value
        }
        set {
            try? store(UserDefaults.keyLastUpdatedTrustList, value: newValue as Any)
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
}
