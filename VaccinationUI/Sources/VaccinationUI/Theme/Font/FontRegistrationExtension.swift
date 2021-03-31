//
//  FontRegistrationExtension.swift
//  
//
//  Copyright © 2021 IBM. All rights reserved.
//

import Foundation
import UIKit

extension UIFont {
    
    static let sansSemiBold = "IBMPlexSans-SemiBold"
    static let sansRegular = "IBMPlexSans"
    static let otfExtension = "otf"
    
    public static func loadCustomFonts() throws {
        try? UIFont.register(with: sansSemiBold, bundle: Bundle.module,  fontExtension: otfExtension)
        try? UIFont.register(with: sansRegular, bundle:Bundle.module, fontExtension: otfExtension)
    }
    
    public static func unloadCustomFonts() throws {
        try? UIFont.unregister(with: sansSemiBold, bundle: Bundle.module, fontExtension: otfExtension)
        try? UIFont.unregister(with: sansRegular, bundle:Bundle.module, fontExtension: otfExtension)
    }
    
    public static func ibmPlexSansSemiBold(with size: CGFloat) -> UIFont? {
        UIFont(name: sansSemiBold, size: size)
    }
    
    public static func ibmPlexSansRegular(with size: CGFloat) -> UIFont? {
        UIFont(name: sansRegular, size: size)
    }
    
    static func cgFont(with name: String, bundle: Bundle, fontExtension: String) throws -> CGFont {
        guard let fontURL = bundle.url(forResource: name, withExtension: fontExtension),
              let fontDataProvider = CGDataProvider(url: fontURL as CFURL),
              let font = CGFont(fontDataProvider) else {
            throw FontLoadingError.other("Couldn't find font \(name)")
        }
        return font
    }
    
    static func register(with name: String, bundle: Bundle, fontExtension: String) throws {
        let font = try cgFont(with: name, bundle: bundle, fontExtension: fontExtension)
        var error: Unmanaged<CFError>?
        let success = CTFontManagerRegisterGraphicsFont(font, &error)
        guard success else {
            throw FontLoadingError.other("Error registering font: maybe it was already registered. \(error.debugDescription)")
        }
    }
    
    static func unregister(with name: String, bundle: Bundle, fontExtension: String) throws {
        let font = try cgFont(with: name, bundle: bundle, fontExtension: fontExtension)
        var error: Unmanaged<CFError>?
        let success = CTFontManagerUnregisterGraphicsFont(font, &error)
        guard success else {
            throw FontLoadingError.other("Error unregistering font: maybe it was already unregistered. \(error.debugDescription)")
        }
    }
}
