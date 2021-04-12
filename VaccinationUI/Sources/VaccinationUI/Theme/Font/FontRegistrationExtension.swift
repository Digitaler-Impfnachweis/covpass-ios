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
    
    static func register(with name: String, bundle: Bundle = Bundle.module, fontExtension: String) throws {
        guard let url = bundle.url(forResource: name, withExtension: fontExtension) else { return }
        var errorRef: Unmanaged<CFError>?
        let success = CTFontManagerRegisterFontsForURL(url as CFURL, .none, &errorRef)
        guard success else {
            throw FontLoadingError.other("Error registering font: maybe it was already registered. \(errorRef.debugDescription)")
        }
    }
    
    static func unregister(with name: String, bundle: Bundle = Bundle.module, fontExtension: String) throws {
        guard let url = bundle.url(forResource: name, withExtension: fontExtension) else { return }
        var errorRef: Unmanaged<CFError>?
        let success = CTFontManagerUnregisterFontsForURL(url as CFURL, .none, &errorRef)
        guard success else {
            throw FontLoadingError.other("Error registering font: maybe it was already registered. \(errorRef.debugDescription)")
        }
    }
}
