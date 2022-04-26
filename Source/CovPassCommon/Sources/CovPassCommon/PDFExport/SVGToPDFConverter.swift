//
//  SVGToPDFConverter.swift
//  
//
//  Created by Thomas Kuleßa on 03.03.22.
//

import PromiseKit
import PDFKit
import UIKit
import WebKit

public final class SVGToPDFConverter: NSObject, SVGToPDFConverterProtocol {
    private lazy var webView: WKWebView = {
        let config = WKWebViewConfiguration()
        config.preferences.javaScriptEnabled = false
        if #available(iOS 14.0, *) {
            config.defaultWebpagePreferences.allowsContentJavaScript = false
        }
        let webView = WKWebView(frame: .zero, configuration: config)
        return webView
    }()

    private var resolver: Resolver<PDFDocument>?

    public func convert(_ svgData: Data) -> Promise<PDFDocument> {
        guard let svgString = String(data: svgData, encoding: .utf8) else {
            return .init(error: SVGToPDFConverterError())
        }
        let (promise, resolver) = Promise<PDFDocument>.pending()
        self.resolver = resolver

        webView.navigationDelegate = self

        // temporarily add the webview to the general view hierarchy
        webView.frame = UIApplication.shared.keyWindow?.bounds ?? .zero
        // the webview has to be visible – nobody said how much…
        // this HACK prevents the screen to 'blink' during page rendering and PDF export
        webView.alpha = 0.01
        UIApplication.shared.keyWindow?.addSubview(webView)

        let header = """
            <html>
            <head>
            <meta charset="utf-8">
            <meta name="viewport" content="width=device-width, initial-scale=1">
            <link rel="preconnect" href="https://fonts.googleapis.com">
            <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
            <link href="https://fonts.googleapis.com/css2?family=Open+Sans:ital@1&display=swap" rel="stylesheet">
            </head>
            <div>
            \(svgString)
            </div>
            </html>
        """

        webView.loadHTMLString(header, baseURL: nil)

        return promise
    }
}

extension SVGToPDFConverter: WKNavigationDelegate {
    public func webView(_ webView: WKWebView, didFinish _: WKNavigation!) {
        defer {
            webView.removeFromSuperview()
        }
        do {
            let pdf = try webView.exportAsPDF()
            resolver?.fulfill(pdf)
        } catch {
            assertionFailure("Export error: \(error)")
            resolver?.reject(SVGToPDFConverterError())
        }
    }
}
