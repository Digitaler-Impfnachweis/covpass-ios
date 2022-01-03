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
}
