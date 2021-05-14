//
//  VoiceOverOptions.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import UIKit

public struct VoiceOverOptions {
    public struct Settings {
        public var label: String?
        public var hint: String?
        public var traits: UIAccessibilityTraits?

        public init() {}
    }

    /// Options for custom voice over header strings
    public var header: Settings?

    /// Options for custom voice over subHeader strings
    public var subHeader: Settings?

    /// Options for custom voice over close button strings
    public var closeButton: Settings?

    /// Options for custom voice over primary button strings
    public var primaryButton: Settings?

    /// Options for custom voice over left button strings
    public var leftButton: Settings?

    /// Options for custom voice over right button strings
    public var rightButton: Settings?

    public init() {}
}
