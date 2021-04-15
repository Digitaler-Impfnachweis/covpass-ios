//
//  UserDefaults.swift
//  
//
//  Copyright © 2021 IBM. All rights reserved.
//

import Foundation

public protocol UserDefaultsSettable {
    associatedtype defaultKeys: RawRepresentable
}

public extension UserDefaultsSettable where defaultKeys.RawValue==String {
    static func set(_ value: Bool, forKey key: defaultKeys) {
        UserDefaults.standard.set(value, forKey: key.rawValue)
    }

    static func bool(_ key: defaultKeys) -> Bool {
        return UserDefaults.standard.bool(forKey: key.rawValue)
    }

    static func remove(_ key: defaultKeys) {
        UserDefaults.standard.removeObject(forKey: key.rawValue)
    }
}

public extension UserDefaults {
    struct StartupInfo: UserDefaultsSettable {
        public enum defaultKeys: String {
            case onboarding
        }
    }
}
