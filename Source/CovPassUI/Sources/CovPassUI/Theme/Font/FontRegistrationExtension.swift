//
//  FontRegistrationExtension.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import UIKit

public extension UIFont {
    // MARK: - Supported fonts name

    static let sansBold = "OpenSans-Bold"
    static let sansSemiBold = "OpenSans-SemiBold"
    static let sansRegular = "OpenSans-Regular"

    static var scaledHeadline: UIFont {
        let font = UIFont(name: UIFont.sansBold, size: 18.0) ?? UIFont.systemFont(ofSize: 18.0)
        let fontMetrics = UIFontMetrics(forTextStyle: .body)
        return fontMetrics.scaledFont(for: font, maximumPointSize: 36.0, compatibleWith: nil)
    }

    static var scaledBody: UIFont {
        let font = UIFont(name: UIFont.sansRegular, size: 14.0) ?? UIFont.systemFont(ofSize: 14.0)
        let fontMetrics = UIFontMetrics(forTextStyle: .body)
        return fontMetrics.scaledFont(for: font, maximumPointSize: 28.0, compatibleWith: nil)
    }

    static var scaledBoldBody: UIFont {
        let font = UIFont(name: UIFont.sansBold, size: 14.0) ?? UIFont.systemFont(ofSize: 14.0)
        let fontMetrics = UIFontMetrics(forTextStyle: .body)
        return fontMetrics.scaledFont(for: font, maximumPointSize: 28.0, compatibleWith: nil)
    }

    // MARK: - Load and unload fonts

    static func loadCustomFonts() {
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
