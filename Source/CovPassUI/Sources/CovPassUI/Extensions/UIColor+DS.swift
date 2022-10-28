//
//  Colors+DS.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import UIKit

public extension UIColor {
    // MARK: - Primary Colors

    static let brandBase = UIColor("BrandBase")
    
    static let brandBase80 = UIColor("BrandBase80")

    static let onBrandBase = UIColor("OnBrandBase")

    static let onBrandAccent = UIColor("OnBrandAccent")

    static let onBrandAccent70 = UIColor("OnBrandAccent70")
    
    static let onBackground20 = UIColor("OnBackground20")

    static let onBackground40 = UIColor("OnBackground40")

    static let onBackground50 = UIColor("OnBackground50")

    static let onBackground70 = UIColor("OnBackground70")

    static let onBackground80 = UIColor("OnBackground80")

    static let onBackground100 = UIColor("OnBackground100")

    static let onBackground110 = UIColor("OnBackground110")

    static let backgroundPrimary = UIColor("BackgroundPrimary")

    static let backgroundSecondary = UIColor("BackgroundSecondary")
    
    static let greyDark = UIColor("greyDark")

    static let backgroundSecondary20 = UIColor("BackgroundSecondary20")
    
    static let backgroundSecondary30 = UIColor("BackgroundSecondary30")

    static let backgroundSecondary40 = UIColor("BackgroundSecondary40")

    static let backgroundPrimary100 = UIColor("backgroundSecondary100")
    
    static let brandAccent = UIColor("BrandAccent")

    static let brandAccent10 = UIColor("BrandAccent10")

    static let brandAccent20 = UIColor("BrandAccent20")

    static let brandAccent30 = UIColor("BrandAccent30")

    static let brandAccent70 = UIColor("BrandAccent70")

    static let brandAccent90 = UIColor("brandAccent90")
    
    static let brandAccentPurple = UIColor("BrandAccentPurple")

    static let brandAccentBlue = UIColor("BrandAccentBlue")

    static let primaryButtonShadow = UIColor("PrimaryButtonShadow")

    static let infoAccent = UIColor("InfoAccent")

    static let infoBackground = UIColor("InfoBackground")

    static let divider = UIColor("Divider")

    // MARK: - Neutral Colors

    static let neutralBlack = UIColor("NeutralBlack")

    static let neutralWhite = UIColor("NeutralWhite")

    // MARK: - Neutral Status

    static let error = UIColor("Error")

    static let success = UIColor("Success")

    static let warning = UIColor("Warning")
    
    static let warningAlternative = UIColor("WarningAlternative")

    static let info = UIColor("Info")

    // MARK: - Result

    static let resultGreen = UIColor("ResultGreen")

    static let resultGreenBackground = UIColor("ResultGreenBackground")

    static let resultYellow = UIColor("ResultYellow")

    static let resultYellowBackground = UIColor("ResultYellowBackground")

    static let resultRed = UIColor("ResultRed")

    static let resultRedBackground = UIColor("ResultRedBackground")
    
    static let statusRedDot = UIColor("StatusRedDot")
}

private extension UIColor {
    convenience init(_ catalogColor: String) {
        self.init(named: catalogColor, in: .module, compatibleWith: nil)!
    }
}
