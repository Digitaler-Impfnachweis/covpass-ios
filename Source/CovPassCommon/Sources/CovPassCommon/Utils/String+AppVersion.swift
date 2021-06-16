//
//  Bundle+AppVersion.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
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
