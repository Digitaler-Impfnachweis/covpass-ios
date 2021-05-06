//
//  File.swift
//  
//
//  Copyright © 2021 IBM. All rights reserved.
//

import UIKit

public enum MainButtonStyle {
    case primary
    case secondary
    case tertiary

    public var textColor: UIColor {
        switch self {
        case .primary:
            return .neutralWhite
        case .secondary:
            return .neutralBlack
        case .tertiary:
            return .neutralBlack
        }
    }

    public var selectedTextColor: UIColor {
        switch self {
        case .primary:
            return .neutralWhite
        case .secondary:
            return .neutralBlack
        case .tertiary:
            return .neutralBlack
        }
    }

    public var highlightedTextColor: UIColor {
        switch self {
        case .primary:
            return .neutralWhite
        case .secondary:
            return .neutralBlack
        case .tertiary:
            return .neutralBlack
        }
    }

    public var disabledTextColor: UIColor {
        switch self {
        case .primary:
            return .onBackground70
        case .secondary:
            return .neutralBlack
        case .tertiary:
            return .neutralBlack
        }
    }

    public var backgroundColor: UIColor {
        switch self {
        case .primary:
            return .brandBase
        case .secondary:
            return .backgroundSecondary
        case .tertiary:
            return .onBackground20
        }
    }

    public var selectedBackgroundColor: UIColor {
        switch self {
        case .primary:
            return .brandAccent
        case .secondary:
            return .backgroundSecondary
        case .tertiary:
            return .onBackground20
        }
    }

    public var highlightedBackgroundColor: UIColor {
        switch self {
        case .primary:
            return .brandBase
        case .secondary:
            return .backgroundSecondary
        case .tertiary:
            return .onBackground20
        }
    }

    public var disabledBackgroundColor: UIColor {
        switch self {
        case .primary:
            return .backgroundSecondary20
        case .secondary:
            return .backgroundSecondary
        case .tertiary:
            return .backgroundSecondary20
        }
    }

    public var borderColor: UIColor? {
        switch self {
        case .primary:
            return .clear
        case .secondary:
            return .onBackground20
        case .tertiary:
            return .clear
        }
    }

    public var selectedBorderColor: UIColor? {
        switch self {
        case .primary:
            return .clear
        case .secondary:
            return .onBackground20
        case .tertiary:
            return .clear
        }
    }

    public var highlightedBorderColor: UIColor? {
        switch self {
        case .primary:
            return .clear
        case .secondary:
            return .onBackground20
        case .tertiary:
            return .clear
        }
    }

    public var disabledBorderColor: UIColor? {
        switch self {
        case .primary:
            return .clear
        case .secondary:
            return .onBackground20
        case .tertiary:
            return .clear
        }
    }

    public var shadowColor: UIColor? {
        switch self {
        case .primary:
            return .primaryButtonShadow
        case .secondary:
            return .clear
        case .tertiary:
            return .clear
        }
    }

    public var disabledShadowColor: UIColor? {
        .clear
    }
}
