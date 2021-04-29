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

    public var textColor: UIColor {
        switch self {
        case .primary:
            return .neutralWhite
        case .secondary:
            return .neutralBlack
        }
    }

    public var selectedTextColor: UIColor {
        switch self {
        case .primary:
            return .neutralWhite
        case .secondary:
            return .neutralBlack
        }
    }

    public var highlightedTextColor: UIColor {
        switch self {
        case .primary:
            return .neutralWhite
        case .secondary:
            return .neutralBlack
        }
    }

    public var disabledTextColor: UIColor {
        switch self {
        case .primary:
            return .neutralWhite
        case .secondary:
            return .neutralBlack
        }
    }

    public var backgroundColor: UIColor {
        switch self {
        case .primary:
            return .brandAccent
        case .secondary:
            return .neutralWhite
        }
    }

    public var selectedBackgroundColor: UIColor {
        switch self {
        case .primary:
            return .primaryPressed
        case .secondary:
            return .primaryPressed
        }
    }

    public var highlightedBackgroundColor: UIColor {
        switch self {
        case .primary:
            return .primaryPressed
        case .secondary:
            return .primaryPressed
        }
    }

    public var disabledBackgroundColor: UIColor {
        switch self {
        case .primary:
            return .primaryPressed
        case .secondary:
            return .primaryPressed
        }
    }

    public var borderColor: UIColor? {
        switch self {
        case .primary:
            return .clear
        case .secondary:
            return .brandAccent
        }
    }

    public var selectedBorderColor: UIColor? {
        switch self {
        case .primary:
            return .clear
        case .secondary:
            return .brandAccent
        }
    }

    public var highlightedBorderColor: UIColor? {
        switch self {
        case .primary:
            return .clear
        case .secondary:
            return .brandAccent
        }
    }

    public var disabledBorderColor: UIColor? {
        switch self {
        case .primary:
            return .clear
        case .secondary:
            return .brandAccent
        }
    }

    public var shadowColor: UIColor? {
        switch self {
        case .primary:
            return UIColor(hexString: "#8B8B8B").withAlphaComponent(0.5)
        case .secondary:
            return .clear
        }
    }
}
