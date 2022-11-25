//
//  LinkTextView.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import UIKit

public class LinkTextView: UITextView {
    public convenience init() {
        self.init()
        setupDefaults()
    }

    override open func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setupDefaults()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupDefaults()
    }

    func setupDefaults() {
        linkTextAttributes = [.foregroundColor: UIColor.brandAccent,
                              .underlineStyle: 1]
    }

    override public func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        super.didUpdateFocus(in: context, with: coordinator)
        updateFocusBorderView()
    }
}
