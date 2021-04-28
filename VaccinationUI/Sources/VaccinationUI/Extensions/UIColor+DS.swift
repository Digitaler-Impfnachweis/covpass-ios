//
//  Colors+DS.swift
//
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

import UIKit

public extension UIColor {
    // MARK: - Primary Colors

    /// bg/primary/base #6AA500
    static let primaryBase = UIColor("PrimaryBase")

    /// bg/primary/disabled #6AA500
    static let primaryDisabled = UIColor("PrimaryDisabled")

    /// bg/primary/hover #5F9400
    static let primaryHover = UIColor("PrimaryHover")

    /// bg/primary/pressed #538200
    static let primaryPressed = UIColor("PrimaryPressed")

    // MARK: - Neutral Colors

    /// bg/neutral/black #000000
    static let neutralBlack = UIColor("NeutralBlack")

    /// bg/neutral/white #FFFFFF
    static let neutralWhite = UIColor("NeutralWhite")

    // MARK: - Neutral Status

    /// bg/status/error #D90000
    static let error = UIColor("Error")

    /// bg/status/success #6AA500
    static let success = UIColor("Success")

    /// bg/status/warning #FECB00
    static let warning = UIColor("Warning")

    /// bg/status/info ##0097BD
    static let info = UIColor("Info")
}

private extension UIColor {
    convenience init(_ catalogColor: String) {
        self.init(named: catalogColor, in: UIConstants.bundle, compatibleWith: nil)!
    }
}
