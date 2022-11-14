//
//  UIScreenExtension.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import UIKit

public extension UIScreen {
    static var isLandscape: Bool {
        UIScreen.main.bounds.size.width > UIScreen.main.bounds.size.height
    }
}
