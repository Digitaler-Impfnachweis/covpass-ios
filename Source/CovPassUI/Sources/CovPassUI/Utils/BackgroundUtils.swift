//
//  BackgroundUtils.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import UIKit

public enum BackgroundUtils {
    static let hideViewTag = 01_071_991
    static let imageViewSize: CGFloat = 100

    static var appIcon: UIImage? {
        if let icons = Bundle.main.infoDictionary?["CFBundleIcons"] as? [String: Any],
           let primary = icons["CFBundlePrimaryIcon"] as? [String: Any],
           let files = primary["CFBundleIconFiles"] as? [String],
           let icon = files.last
        {
            return UIImage(named: icon)
        }
        return nil
    }

    public static func addHideView(to window: UIWindow?) {
        guard let window = window else { return }
        let hideView = UIView(frame: window.frame)
        hideView.backgroundColor = .white
        let imageView = UIImageView(frame: .zero)
        imageView.image = appIcon
        hideView.addSubview(imageView)
        hideView.tag = BackgroundUtils.hideViewTag
        window.addSubview(hideView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.centerYAnchor.constraint(equalTo: hideView.centerYAnchor).isActive = true
        imageView.centerXAnchor.constraint(equalTo: hideView.centerXAnchor).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: imageViewSize).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: imageViewSize).isActive = true
    }

    public static func removeHideView(from window: UIWindow?) {
        guard let window = window else { return }
        window.viewWithTag(BackgroundUtils.hideViewTag)?.removeFromSuperview()
    }
}
