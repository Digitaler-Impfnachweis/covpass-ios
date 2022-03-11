//
//  ListContentItem.swift
//  
//
//  Created by Thomas Kuleßa on 09.03.22.
//

/// Model class for list items of the form title/value.
public struct ListContentItem {
    public let label: String
    public let value: String
    public let accessibilityLabel: String?
    public let accessibilityIdentifier: String?

    public init(_ label: String,
                _ value: String,
                _ accessibilityLabel: String? = nil,
                _ accessibilityIdentifier: String? = nil) {
        self.init(
            label: label,
            value: value,
            accessibilityLabel: accessibilityLabel,
            accessibilityIdentifier: accessibilityIdentifier
        )
    }

    public init(label: String,
                value: String, accessibilityLabel: String? = nil,
                accessibilityIdentifier: String? = nil) {
        self.label = label
        self.value = value
        self.accessibilityLabel = accessibilityLabel ?? "\(label)\n\(value)" // break adds a pause
        self.accessibilityIdentifier = accessibilityIdentifier
    }
}

