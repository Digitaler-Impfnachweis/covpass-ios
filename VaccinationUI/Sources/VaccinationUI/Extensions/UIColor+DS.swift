//
//  Colors+DS.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

import UIKit

public extension UIColor {
    // MARK: - Primary Colors

    static let brandBase = UIColor("BrandBase")

    static let onBrandBase = UIColor("OnBrandBase")

    static let onBrandAccent = UIColor("OnBrandAccent")

    static let onBrandAccent70 = UIColor("OnBrandAccent70")

    static let onBackground20 = UIColor("OnBackground20")

    static let onBackground50 = UIColor("OnBackground50")

    static let onBackground70 = UIColor("OnBackground70")

    static let onBackground100 = UIColor("OnBackground100")

    static let backgroundPrimary = UIColor("BackgroundPrimary")

    static let backgroundSecondary = UIColor("BackgroundSecondary")

    static let backgroundSecondary20 = UIColor("BackgroundSecondary20")

    static let backgroundPrimary100 = UIColor("backgroundSecondary100")

    static let brandAccent = UIColor("BrandAccent")

    static let brandAccent10 = UIColor("BrandAccent10")

    static let brandAccent20 = UIColor("BrandAccent20")

    static let brandAccent70 = UIColor("BrandAccent70")

    static let primaryButtonShadow = UIColor("PrimaryButtonShadow")

    // MARK: - Neutral Colors

    static let neutralBlack = UIColor("NeutralBlack")

    static let neutralWhite = UIColor("NeutralWhite")

    // MARK: - Neutral Status

    static let error = UIColor("Error")

    static let success = UIColor("Success")

    static let warning = UIColor("Warning")

    static let info = UIColor("Info")
}

private extension UIColor {
    convenience init(_ catalogColor: String) {
        self.init(named: catalogColor, in: .module, compatibleWith: nil)!
    }
}
