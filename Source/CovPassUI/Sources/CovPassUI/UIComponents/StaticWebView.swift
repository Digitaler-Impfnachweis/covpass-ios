//
//  StaticWebView.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import WebKit

extension UIFont {
    static var scaledHeadline: UIFont {
        let font = UIFont(name: UIFont.sansBold, size: 18.0) ?? UIFont.systemFont(ofSize: 18.0)
        let fontMetrics = UIFontMetrics(forTextStyle: .body)
        return fontMetrics.scaledFont(for: font, maximumPointSize: 36.0, compatibleWith: nil)
    }

    static var scaledBody: UIFont {
        let font = UIFont(name: UIFont.sansRegular, size: 14.0) ?? UIFont.systemFont(ofSize: 14.0)
        let fontMetrics = UIFontMetrics(forTextStyle: .body)
        return fontMetrics.scaledFont(for: font, maximumPointSize: 28.0, compatibleWith: nil)
    }
}

public class StaticWebView: WKWebView, WKNavigationDelegate {
    public var onScrollHeight: ((_ height: CGFloat) -> Void)?

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        navigationDelegate = self
    }

    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if !webView.isLoading {
            setDynamicFont {
                webView.evaluateJavaScript("document.body.scrollHeight", completionHandler: { result, _ in
                    if let height = result as? CGFloat {
                        self.onScrollHeight?(height)
                    }
                })
            }
        }
    }

    public func setDynamicFont(_ completion: (() -> Void)? = nil) {
        evaluateJavaScript("""
var style = document.createElement('style')
style.innerText = "* { font-size: \(UIFont.scaledBody.pointSize)px; } h1 { font-size: \(UIFont.scaledHeadline.pointSize)px; } h2 { font-size: \(UIFont.scaledHeadline.pointSize)px; } h3 { font-size: \(UIFont.scaledBody.pointSize)px; }"
document.head.appendChild(style)
""", completionHandler: { _, _ in completion?() })
    }
}
