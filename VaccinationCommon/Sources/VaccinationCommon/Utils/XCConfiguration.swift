//
//  XCConfiguration.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation

// `Info.plist` accessor utils
public enum XCConfiguration {
    public static func value<T>(_: T.Type, forKey key: String) -> T where T: RawRepresentable, T.RawValue == String {
        guard let object = Bundle.main.object(forInfoDictionaryKey: key) else {
            fatalError("No configuration found for key \(key)")
        }

        guard let string = object as? String, let value = T(rawValue: string) else {
            fatalError("Configuration for key \(key) has invalid type")
        }

        return value
    }

    public static func value<T>(_: T.Type, forKey key: String) -> T where T: LosslessStringConvertible {
        guard let object = Bundle.main.object(forInfoDictionaryKey: key) else {
            fatalError("No configuration found for key \(key)")
        }

        guard let string = object as? String, let value = T(string) else {
            fatalError("Configuration for key \(key) has invalid type")
        }

        return value
    }

    public static func value<T>(_: [T].Type, forKey key: String, seperator: Character = ",") -> [T] where T: LosslessStringConvertible {
        guard let object = Bundle.main.object(forInfoDictionaryKey: key) else {
            fatalError("No configuration found for key \(key)")
        }
        guard let string = object as? String else {
            fatalError("Configuration for key \(key) has invalid type")
        }
        return string
            .split(separator: seperator)
            .map { String($0) }
            .compactMap { T($0) }
    }

    public static func value(_: URL.Type, forKey key: String) -> URL {
        guard let object = Bundle.main.object(forInfoDictionaryKey: key) else {
            fatalError("No configuration found for key \(key)")
        }

        guard let string = object as? String, let value = URL(string: string) else {
            fatalError("Configuration for key \(key) has invalid type")
        }

        return value
    }
}
