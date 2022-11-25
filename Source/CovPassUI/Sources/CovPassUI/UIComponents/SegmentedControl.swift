//
//  SegmentedControl.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import UIKit

public class SegmentedControl: UISegmentedControl {
    override public func layoutSubviews() {
        super.layoutSubviews()

        // Set scaled font
        if let font = UIFont(name: UIFont.sansRegular, size: 14.0) {
            let segmentedControlFont = UIFontMetrics(forTextStyle: .body).scaledFont(for: font, maximumPointSize: 28)
            setTitleTextAttributes([.font: segmentedControlFont], for: .normal)
        }

        // Add line break mode to all controls
        for segmentViews in subviews {
            for segmentLabel in segmentViews.subviews {
                if segmentLabel is UILabel {
                    (segmentLabel as! UILabel).lineBreakMode = .byWordWrapping
                    (segmentLabel as! UILabel).numberOfLines = 0
                }
            }
        }
    }
}
