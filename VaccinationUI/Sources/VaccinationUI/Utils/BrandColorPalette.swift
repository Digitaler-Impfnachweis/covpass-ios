//
//  BrandColorPalette.swift
//  
//
//  Copyright © 2021 IBM. All rights reserved.
//

import UIKit

public protocol BrandColorPalette {
    var brandBase: UIColor { get }
    var onBrandBase: UIColor { get }
    var onBrandAccent: UIColor { get }
    var onBrandAccent70: UIColor { get }
    var onBackground20: UIColor { get }
    var onBackground50: UIColor { get }
    var onBackground70: UIColor { get }
    var onBackground100: UIColor { get }
    var backgroundPrimary: UIColor { get }
    var backgroundSecondary: UIColor { get }
    var brandAccent: UIColor { get }
    var brandAccent20: UIColor { get }
    var brandAccent70: UIColor { get }
}

public class BrandColorPaletteManager: NSObject {
    public static var shared = BrandColorPaletteManager()
    public var colorPalette: BrandColorPalette = BrandDefaultColorPalette()
}

open class BrandDefaultColorPalette: BrandColorPalette, Codable {
    public init() {}

    private var _brandBase: String = "#065FC4"
    open var brandBase: UIColor { UIColor(hexString: _brandBase) }

    private var _onBrandBase: String = "#FFFFFF"
    open var onBrandBase: UIColor { UIColor(hexString: _onBrandBase) }

    private var _onBrandAccent: String = "#FFFFFF"
    open var onBrandAccent: UIColor { UIColor(hexString: _onBrandAccent) }
    
    private var _onBrandAccent70: String = "#666666"
    open var onBrandAccent70: UIColor { UIColor(hexString: _onBrandAccent70) }

    private var _onBackground20: String = "#E4E8EC"
    open var onBackground20: UIColor { UIColor(hexString: _onBackground20) }

    private var _onBackground50: String = "#94A5B2"
    open var onBackground50: UIColor { UIColor(hexString: _onBackground50) }

    private var _onBackground70: String = "#556877"
    open var onBackground70: UIColor { UIColor(hexString: _onBackground70) }

    private var _onBackground100: String = "#1C2227"
    open var onBackground100: UIColor { UIColor(hexString: _onBackground100) }

    private var _backgroundPrimary: String = "#F9F9FB"
    open var backgroundPrimary: UIColor { UIColor(hexString: _backgroundPrimary) }

    private var _backgroundSecondary: String = "#FFFFFF"
    open var backgroundSecondary: UIColor { UIColor(hexString: _backgroundSecondary) }
    
    private var _backgroundPrimary100: String = "#1B1B28"
    open var backgroundPrimary100: UIColor { UIColor(hexString: _backgroundPrimary100) }

    private var _brandAccent: String = "#065FC4"
    open var brandAccent: UIColor { UIColor(hexString: _brandAccent) }

    private var _brandAccent20: String = "#D2E7FE"
    open var brandAccent20: UIColor { UIColor(hexString: _brandAccent20) }

    private var _brandAccent70: String = "#065FC4"
    open var brandAccent70: UIColor { UIColor(hexString: _brandAccent70) }
}
