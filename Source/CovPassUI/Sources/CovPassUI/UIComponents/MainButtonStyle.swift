//
//  MainButtonStyle.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import UIKit

public enum MainButtonStyle {
    case primary
    case secondary
    case tertiary
    case plain
    
    public var textColor: UIColor {
        switch self {
        case .primary:
            return .neutralWhite
        case .secondary:
            return .neutralBlack
        case .tertiary:
            return .neutralBlack
        case .plain:
            return .brandBase
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
        case .plain:
            return .brandBase
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
        case .plain:
            return .brandBase
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
        case .plain:
            return .onBackground70
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
        case .plain:
            return .clear
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
        case .plain:
            return .clear
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
        case .plain:
            return .clear
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
        case .plain:
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
        case .plain:
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
        case .plain:
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
        case .plain:
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
        case .plain:
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
        case .plain:
            return .clear
        }
    }
    
    public var disabledShadowColor: UIColor? {
        .clear
    }
}
