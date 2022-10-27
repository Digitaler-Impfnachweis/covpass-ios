//
//  FontRegistrationExtension.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import UIKit

extension UIFont {
    // MARK: - Supported fonts name

    static let sansBold = "OpenSans-Bold"
    static let sansSemiBold = "OpenSans-SemiBold"
    static let sansRegular = "OpenSans-Regular"

    // MARK: - Load and unload fonts

    public static func loadCustomFonts() {
        do {
            try UIFont.register(with: sansBold, bundle: .module)
            try UIFont.register(with: sansSemiBold, bundle: .module)
            try UIFont.register(with: sansRegular, bundle: .module)
        } catch {
            print("Failed to load custom fonts \(error)")
        }
    }

    // MARK: - Register Font

    private static func register(with name: String, bundle: Bundle) throws {
        guard let fontData = NSDataAsset(name: name, bundle: bundle)?.data,
              let fontDataProvider = CGDataProvider(data: fontData as CFData),
              let font = CGFont(fontDataProvider)
        else {
            throw FontLoadingError.other("Error registering font \(name). Maybe it was already registered.")
        }
        var error: Unmanaged<CFError>?
        guard CTFontManagerRegisterGraphicsFont(font, &error) else {
            throw error!.takeUnretainedValue()
        }
    }
}
