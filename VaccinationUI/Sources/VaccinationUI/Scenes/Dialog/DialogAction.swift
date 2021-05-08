//
//  DialogAction.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

import UIKit

public struct DialogAction {
    // MARK: - Properties

    public let title: String
    public let completion: ((Self) -> Void)?
    public let style: UIAlertAction.Style?
    public let isEnabled: Bool

    // MARK: - Lifecycle

    public init(
        title: String,
        style: UIAlertAction.Style? = .default,
        isEnabled: Bool = true,
        completion: ((Self) -> Void)? = nil
    ) {
        self.title = title
        self.completion = completion
        self.style = style
        self.isEnabled = isEnabled
    }

    // MARK: - Methods

    public static func cancel(_ title: String = "Cancel") -> DialogAction {
        DialogAction(title: title, style: .cancel)
    }
}

extension DialogAction: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.title == rhs.title && lhs.style == rhs.style && lhs.isEnabled == rhs.isEnabled
    }
}
