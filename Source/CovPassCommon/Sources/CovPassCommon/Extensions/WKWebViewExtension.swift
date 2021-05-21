//
//  WKWebViewExtension.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import WebKit

public extension WKWebView {
    /// Enables text scaling for WKWebView
    ///
    /// The scaling factor is calculated based on UIFontMetricts for the body text style
    /// Important the website needs to support proper text scaling and should not use fixed pixel values
    func enableTextScaling() {
        let fontMetrics = UIFontMetrics(forTextStyle: .body)
        let scalingFactor = Int(fontMetrics.scaledValue(for: 10)) * 10
        let cssStyle = """
            javascript:(function() {
            var parent = document.getElementsByTagName('head').item(0);
            var style = document.createElement('style');
            style.type = 'text/css';
            style.innerHTML = '* { font-size: \(scalingFactor)%; }';
            parent.appendChild(style)})()
        """
        let script = WKUserScript(source: cssStyle, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
        self.configuration.userContentController.addUserScript(script)
    }
}
