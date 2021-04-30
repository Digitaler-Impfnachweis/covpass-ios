//
//  FontRegistrationExtension.swift
//  
//
//  Copyright © 2021 IBM. All rights reserved.
//

import Foundation
import UIKit

extension UIFont {
    
    // MARK: - Supported fonts name
    
    static let sansSemiBold = "IBMPlexSans-SemiBold"
    static let sansRegular = "IBMPlexSans"
    
    // MARK: - Predefiend Font
    
    public static func ibmPlexSansSemiBold(with size: CGFloat) -> UIFont? {
        UIFont(name: sansSemiBold, size: size)
    }
    
    public static func ibmPlexSansRegular(with size: CGFloat) -> UIFont? {
        UIFont(name: sansRegular, size: size)
    }
    
    // MARK: - Register Predefined Fonts
    
    public static func loadCustomFonts() throws {
        try? UIFont.register(with: sansSemiBold, bundle: .module)
        try? UIFont.register(with: sansRegular, bundle: .module)
    }

    // MARK: - Supported fonts name
    
    public static func unloadCustomFonts() throws {
        try? UIFont.unregister(with: sansSemiBold, bundle: Bundle.module)
        try? UIFont.unregister(with: sansRegular, bundle:Bundle.module)
    }
    
    // MARK: - Register Font 

    public static func register(with name: String, bundle: Bundle) throws {
        guard let fontData = NSDataAsset(name: name, bundle: bundle)?.data,
              let fontDataProvider = CGDataProvider(data: fontData as CFData),
              let font = CGFont(fontDataProvider) else {
            throw FontLoadingError.other("Error registering font \(name). Maybe it was already registered.")
        }
        var error: Unmanaged<CFError>?
        guard CTFontManagerRegisterGraphicsFont(font, &error) else {
            throw error!.takeUnretainedValue()
        }
    }

    // MARK: - Unregister Font

    public static func unregister(with name: String, bundle: Bundle) throws {
        guard let fontData = NSDataAsset(name: name, bundle: bundle)?.data,
              let fontDataProvider = CGDataProvider(data: fontData as CFData),
              let font = CGFont(fontDataProvider) else {
            throw FontLoadingError.other("Fail to unregister font \(name)")
        }
        var error: Unmanaged<CFError>?
        guard CTFontManagerUnregisterGraphicsFont(font, &error) else {
            throw error!.takeUnretainedValue()
        }
    }
}
