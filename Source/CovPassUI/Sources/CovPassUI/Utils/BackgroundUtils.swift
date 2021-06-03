//
//  BackgroundUtils.swift
//  
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import UIKit

public class BackgroundUtils {
    static let hideViewTag = 01_071_991
    static let imageViewHeight: CGFloat = 300

    public static func addHideView(to window: UIWindow?) {
        guard let window = window else { return }
        let hideView = UIView(frame: window.frame)
        hideView.backgroundColor = .white
        let imageView = UIImageView(frame: .init(x: 0, y: 0, width: hideView.frame.width, height: BackgroundUtils.imageViewHeight))
        imageView.image = .onboardingScreen1
        hideView.addSubview(imageView)
        hideView.tag = BackgroundUtils.hideViewTag
        window.addSubview(hideView)
    }

    public static func removeHideView(from window: UIWindow?) {
        guard let window = window else { return }
        window.viewWithTag(BackgroundUtils.hideViewTag)?.removeFromSuperview()
    }
}
