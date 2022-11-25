//
// UIView+KeyboardFocus.swift
// IBMHealthUI
//
// Created by Gocz Hunor on 07.03.2022.
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import UIKit
/// This class is for supporting full keyboard access for our components. Updates the visibility of the view’s focus view based on the `isFocused` property. If it’s focused then it adds the `HUIFocusBorderView` as subview, otherwise removes it.
public class FocusBorderManager {
    public static let shared = FocusBorderManager()
    private var notificationCenterObserver: Any?
    private init() {
        notificationCenterObserver = NotificationCenter.default.addObserver(forName: UIFocusSystem.didUpdateNotification, object: nil, queue: nil) { [weak self] _ in
            self?.removeFocusBorder()
        }
    }

    private var focusBorderViews: [HUIFocusBorderView] = []
    public func updateFocusBorderView(customFrame: CGRect? = nil, view: UIView) {
        removeFocusBorder()
        // add focus border with delay, otherwise UIFocusSystem.didUpdateNotification is triggered afterwards and removes focus border
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(30)) {
            self.addFocusBorder(customFrame: customFrame, view: view)
        }
    }

    private func addFocusBorder(customFrame: CGRect? = nil, view: UIView) {
        guard view.isFocused else { return }
        let focusBorderView = HUIFocusBorderView(frame: customFrame ?? view.bounds, cornerRadius: view.layer.cornerRadius)
        view.addSubview(focusBorderView)
        view.layer.masksToBounds = false
        focusBorderViews.append(focusBorderView)
    }

    private func removeFocusBorder() {
        for view in focusBorderViews {
            view.removeFromSuperview()
        }
        focusBorderViews = []
    }
}
