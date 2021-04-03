//
//  UIConstants.swift
//  
//
//  Copyright © 2021 IBM. All rights reserved.
//

import UIKit

open class UIConstants {
    // use a class from same package to identify the package
    open class var bundle: Bundle {
        return Bundle(for: CustomToolbarView.self)
    }

    public static let brandColorPalette: BrandColorPalette = BrandColorPaletteManager.shared.colorPalette

    open class IconName {
        public static let NavigationArrow = "ega_back_arrow"
        public static let Edit = "hui_icon_edit"
        public static let Search = "hui_icon_search"
        public static let CancelButton = "hui_cancel"
        public static let PlusIcon = "plus"
        public static let CheckmarkIcon = "check"
        public static let RgArrowDown = "ega_rg_arrow_down"
    }

    open class BrandColor {
        public static let onBrandAccent = brandColorPalette.onBrandAccent
        public static let onBackground20 = brandColorPalette.onBackground20
        public static let onBackground50 = brandColorPalette.onBackground50
        public static let onBackground70 = brandColorPalette.onBackground70
        public static let backgroundSecondary = brandColorPalette.backgroundSecondary
        public static let brandAccent70 = brandColorPalette.brandAccent70
        public static let brandAccent = brandColorPalette.brandAccent
        public static let primaryButtonShadow = UIColor(hexString: "#8B8B8B").withAlphaComponent(0.5)
    }

    open class Size {
        public static let CancelButtonSize: CGFloat = 56
        public static let MiddleButtonSize: CGFloat = 56
        public static let ButtonCornerRadius: CGFloat = 28
        public static let ButtonShadowRadius: CGFloat = 9
        public static let ButtonDotPulseAnimationPadding: CGFloat = 5
        public static let ButtonAnimatingSize: CGFloat = 56
        public static let PrimaryButtonMargin: CGFloat = 24
    }

    public struct Animation {
        public static let DotPulseAnimationDotsNumber = 3
        public static let Duration = 0.5
    }
}
