//
//  StringExtension.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import WebKit

public extension WKWebView {
    func enableTextScaling() {
        let font = UIFont.systemFont(ofSize: 10.0)
        let fontMetrics = UIFontMetrics(forTextStyle: .body)
        let scaledFont = fontMetrics.scaledFont(for: font, compatibleWith: traitCollection)
        let scalingFactor = Int(((scaledFont.pointSize / font.pointSize) * 100))
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
