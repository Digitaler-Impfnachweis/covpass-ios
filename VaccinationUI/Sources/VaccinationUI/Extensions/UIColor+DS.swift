//
//  Colors+DS.swift
//
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

import UIKit

extension UIColor {
    // MARK: - Primary Colors

    public static let brandBase = UIColor("BrandBase")

    public static let onBrandBase = UIColor("OnBrandBase")

    public static let onBrandAccent = UIColor("OnBrandAccent")

    public static let onBrandAccent70 = UIColor("OnBrandAccent70")

    public static let onBackground20 = UIColor("OnBackground20")

    public static let onBackground50 = UIColor("OnBackground50")

    public static let onBackground70 = UIColor("OnBackground70")

    public static let onBackground100 = UIColor("OnBackground100")

    public static let backgroundPrimary = UIColor("BackgroundPrimary")

    public static let backgroundSecondary = UIColor("BackgroundSecondary")

    public static let backgroundSecondary20 = UIColor("BackgroundSecondary20")

    public static let backgroundPrimary100 = UIColor("backgroundSecondary100")

    public static let brandAccent = UIColor("BrandAccent")

    public static let brandAccent10 = UIColor("BrandAccent10")

    public static let brandAccent20 = UIColor("BrandAccent20")

    public static let brandAccent70 = UIColor("BrandAccent70")

    public static let primaryButtonShadow = UIColor("PrimaryButtonShadow")

    // MARK: - Neutral Colors

    public static let neutralBlack = UIColor("NeutralBlack")

    public static let neutralWhite = UIColor("NeutralWhite")

    // MARK: - Neutral Status

    public static let error = UIColor("Error")

    public static let success = UIColor("Success")

    public static let warning = UIColor("Warning")

    public static let info = UIColor("Info")
}

private extension UIColor {
    convenience init(_ catalogColor: String) {
        self.init(named: catalogColor, in: .module, compatibleWith: nil)!
    }
}
