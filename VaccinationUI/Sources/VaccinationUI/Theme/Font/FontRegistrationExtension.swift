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
    
    public static let sansSemiBold = "IBMPlexSans-SemiBold"
    public static let sansRegular = "IBMPlexSans"
    public static let otfExtension = "otf"
    
    // MARK: - Predefiend Font
    
    public static func ibmPlexSansSemiBold(with size: CGFloat) -> UIFont? {
        UIFont(name: sansSemiBold, size: size)
    }
    
    public static func ibmPlexSansRegular(with size: CGFloat) -> UIFont? {
        UIFont(name: sansRegular, size: size)
    }
    
    // MARK: - Register Font 
    
    public static func register(with name: String, bundle: Bundle, fontExtension: String) throws {
        guard let url = bundle.url(forResource: name, withExtension: fontExtension) else { return }
        var errorRef: Unmanaged<CFError>?
        let success = CTFontManagerRegisterFontsForURL(url as CFURL, .none, &errorRef)
        guard success else {
            throw FontLoadingError.other("Error registering font: maybe it was already registered. \(errorRef.debugDescription)")
        }
    }
    
    public static func unregister(with name: String, bundle: Bundle, fontExtension: String) throws {
        guard let url = bundle.url(forResource: name, withExtension: fontExtension) else { return }
        var errorRef: Unmanaged<CFError>?
        let success = CTFontManagerUnregisterFontsForURL(url as CFURL, .none, &errorRef)
        guard success else {
            throw FontLoadingError.other("Error registering font: maybe it was already registered. \(errorRef.debugDescription)")
        }
    }
}
