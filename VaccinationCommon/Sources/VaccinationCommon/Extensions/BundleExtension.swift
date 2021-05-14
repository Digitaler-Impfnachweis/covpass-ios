//
//  BundleExtension.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation

public extension Bundle {
    static var commonBundle: Bundle {
        Bundle.module
    }
}
