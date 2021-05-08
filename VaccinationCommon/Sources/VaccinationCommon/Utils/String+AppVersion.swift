//
//  Bundle+AppVersion.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

import UIKit

public extension Bundle {
    func appVersion() -> String {
        guard
            let version = infoDictionary?["CFBundleShortVersionString"] as? String,
            let bundleVersion = infoDictionary?["CFBundleVersion"] as? String
        else {
            return "1.0"
        }
        return "\(version) (\(bundleVersion))"
    }
}
