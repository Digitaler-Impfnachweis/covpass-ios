//
//  File.swift
//  
//
//  Created by Sebastian Maschinski on 07.05.21.
//

import UIKit

extension Bundle {
    public func appVersion() -> String {
        guard
            let version = infoDictionary?["CFBundleShortVersionString"] as? String,
            let bundleVersion = infoDictionary?["CFBundleVersion"] as? String else {
            return "1.0"
        }
        return "\(version) (\(bundleVersion))"
    }
}
