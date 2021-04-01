//
//  BrandColorPalette.swift
//  
//
//  Copyright © 2021 IBM. All rights reserved.
//

import UIKit

public protocol BrandColorPalette {
    var onBrandAccent: UIColor { get }
    var onBackground20: UIColor { get }
    var onBackground50: UIColor { get }
    var onBackground70: UIColor { get }
    var backgroundSecondary: UIColor { get }
    var brandAccent70: UIColor { get }
    var brandAccent: UIColor { get }
}

public class BrandColorPaletteManager: NSObject {
    public static var shared = BrandColorPaletteManager()
    public var colorPalette: BrandColorPalette = BrandDefaultColorPalette()
}

open class BrandDefaultColorPalette: BrandColorPalette, Codable {
    public init() {}

    private var _onBrandAccent: String = "#FFFFFF"
    open var onBrandAccent: UIColor { UIColor(hexString: _onBrandAccent) }

    private var _onBackground20: String = "#E4E8EC"
    open var onBackground20: UIColor { UIColor(hexString: _onBackground20) }

    private var _onBackground50: String = "#94A5B2"
    open var onBackground50: UIColor { UIColor(hexString: _onBackground50) }

    private var _onBackground70: String = "#556877"
    open var onBackground70: UIColor { UIColor(hexString: _onBackground70) }

    private var _backgroundSecondary: String = "#FFFFFF"
    open var backgroundSecondary: UIColor { UIColor(hexString: _backgroundSecondary) }

    private var _brandAccent70: String = "#065FC4"
    open var brandAccent70: UIColor { UIColor(hexString: _brandAccent70) }

    private var _brandAccent: String = "#065FC4"
    open var brandAccent: UIColor { UIColor(hexString: _brandAccent) }
}
