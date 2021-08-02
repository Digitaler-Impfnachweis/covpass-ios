//
//  SVGPDFExporter.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import PDFKit
import UIKit
import WebKit

final class SVGPDFExporter: NSObject, WKNavigationDelegate, SVGPDFExportProtocol {

    enum ExportError: Error {
        case invalidTemplate
    }

    /// A web view that does not allow Javascript execution.
    private lazy var webView: WKWebView = {
        // JS is disabled as it's not used/required in our SVGs
        let config = WKWebViewConfiguration()
        config.preferences.javaScriptEnabled = false
        if #available(iOS 14.0, *) {
            config.defaultWebpagePreferences.allowsContentJavaScript = false
        }
        let webView = WKWebView(frame: .zero, configuration: config)
        return webView
    }()

    /// Date formated as `yyyy-MM-dd`.
    private lazy var dateFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate]
        return formatter
    }()

    private var exportHandler: ExportHandler?

    // MARK: - SVGPDFExportProtocol

    func fill(template: Template, with token: ExtendedCBORWebToken) throws -> SVGData? {
        let certificate = token.vaccinationCertificate.hcert.dgc
        guard
            let data = certificate.template?.data,
            var svg = String(data: data, encoding: .utf8)
        else {
            assertionFailure()
            return nil
        }

        // Common fields
        svg = svg.replacingOccurrences(of: "$nam", with: certificate.nam.fullName)
        svg = svg.replacingOccurrences(of: "$dob", with: certificate.dobString ?? .placeholder)
        svg = svg.replacingOccurrences(of: "$ci", with: certificate.uvci)
        // QR code: already base64 encoded
        svg = svg.replacingOccurrences(of: "$qr", with: token.vaccinationQRCodeData)

        switch template.type {
        case .recovery:
            guard let recovery = certificate.latestRecovery else {
                throw ExportError.invalidTemplate
            }
            // disease of agent targeted
            svg = svg.replacingOccurrences(of: "$tg", with: recovery.tg)
            // date of first positive test result
            svg = svg.replacingOccurrences(of: "$fr", with: dateFormatter.string(from: recovery.fr))
            // valid from
            svg = svg.replacingOccurrences(of: "$df", with: dateFormatter.string(from: recovery.df))
            // valid until
            svg = svg.replacingOccurrences(of: "$du", with: dateFormatter.string(from: recovery.du))
        case.test:
            guard let test = certificate.latestTest else {
                throw ExportError.invalidTemplate
            }
            // disease of agent targeted
            svg = svg.replacingOccurrences(of: "$tg", with: test.tg)
            // test type
            svg = svg.replacingOccurrences(of: "$tt", with: test.tt)
            // test name
            svg = svg.replacingOccurrences(of: "$nm", with: test.nm ?? .placeholder)
            // test manufacturer
            svg = svg.replacingOccurrences(of: "$ma", with: test.ma ?? .placeholder)
            // sample collection
            svg = svg.replacingOccurrences(of: "$sc", with: dateFormatter.string(from: test.sc))
            // date test result
            #warning("no sign of `$dr` found!!")
            svg = svg.replacingOccurrences(of: "$dr", with: String.placeholder)
            // test result
            svg = svg.replacingOccurrences(of: "$tr", with: test.tr)
            // testing center
            svg = svg.replacingOccurrences(of: "$tc", with: test.tc)
            // country
            svg = svg.replacingOccurrences(of: "$co", with: test.co)
            // certificate issue
            svg = svg.replacingOccurrences(of: "$is", with: test.is)
        case .vaccination:
            guard let vaccination = certificate.latestVaccination else {
                throw ExportError.invalidTemplate
            }
            // disease of agent targeted
            svg = svg.replacingOccurrences(of: "$tg", with: vaccination.tg)
            // vaccine
            svg = svg.replacingOccurrences(of: "$vp", with: vaccination.vp)
            // vaccine product name
            svg = svg.replacingOccurrences(of: "$mp", with: vaccination.mp)
            // marketing authorization
            svg = svg.replacingOccurrences(of: "$ma", with: vaccination.ma)
            // vaccination x of y - number format is not localized!
            svg = svg.replacingOccurrences(of: "$dn", with: vaccination.dn.description)
            svg = svg.replacingOccurrences(of: "$sd", with: vaccination.sd.description)
            // date vaccination
            svg = svg.replacingOccurrences(of: "$dt", with: dateFormatter.string(from: vaccination.dt))
            // country
            svg = svg.replacingOccurrences(of: "$co", with: vaccination.co)
            // certificate issue
            svg = svg.replacingOccurrences(of: "$is", with: vaccination.is)
        }

        #if DEBUG
        let regex = try! NSRegularExpression(pattern: "\\>\\$\\w+\\<")
        let range = NSRange(location: 0, length: svg.utf16.count)
        if let match = regex.firstMatch(in: svg, options: [], range: range) {
            let nsString = svg as NSString
            let matchString = nsString.substring(with: match.range) as String
            assertionFailure("missed one placeholder: \(matchString)")
        }
        #endif

        return svg.data(using: .utf8)
    }

    func export(_ data: SVGData, completion: ExportHandler?) {
        guard let string = String(data: data, encoding: .utf8) else {
            preconditionFailure("Expected a String")
        }
        webView.navigationDelegate = self
        // completion is called after web view has loaded
        exportHandler = completion

        // temporarily add the webview to the general view hierarchy
        webView.frame = UIApplication.shared.keyWindow?.bounds ?? .zero
        // the webview has to be visible – nobody said how much…
        // this HACK prevents the screen to 'blink' during page rendering and PDF export
        webView.alpha = 0.01
        UIApplication.shared.keyWindow?.addSubview(webView)

        webView.loadHTMLString(string, baseURL: nil)
    }

    // MARK: - WKNavigationDelegate

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        guard webView == self.webView else { return }

        defer {
            webView.removeFromSuperview()
        }
        do {
            let pdf = try webView.exportAsPDF()
            exportHandler?(pdf)
        } catch {
            assertionFailure("Export error: \(error)")
            exportHandler?(nil)
        }
    }
}

// MARK: – Helper Extensions

extension ExtendedCBORWebToken {
    /// Checks if a certificate in the given token can be exported to PDF
    ///
    /// If multiple certificates are present the priotization is as follows (most to least important):
    /// 1. vaccination
    /// 2. test
    /// 3. recovery
    var canExportToPDF: Bool {
        vaccinationCertificate.hcert.dgc.template != nil
    }
}

extension DigitalGreenCertificate {
    /// Checks if the given certificate can be exported
    var canExportToPDF: Bool {
        template != nil
    }

    var latestRecovery: Recovery? {
        r?.sorted(by: { $0.df > $1.df }).first
    }

    var latestTest: Test? {
        t?.sorted(by: { $0.sc > $1.sc }).first
    }

    var latestVaccination: Vaccination? {
        v?.sorted(by: { $0.dt > $1.dt }).first
    }
}

extension DigitalGreenCertificate {

    var template: Template? {
        var name: String? = nil
        var type: Template.TemplateType? = .none
        if let _ = v?.first {
            name = "VaccinationCertificateTemplate_v2_2021-06-03_02_DEMO"
            type = .vaccination
        }
        if let _ = t?.first {
            name = "TestCertificateTemplate_v2_2021-06-03_02_DEMO"
            type = .test
        }
        if let _ = r?.first {
            name = "RecoveryCertificateTemplate_v2_2021-06-03_02_DEMO"
            type = .recovery
        }

        guard let name = name, let type = type else {
            preconditionFailure("Could not determine template type")
        }
        guard
            let templateURL = Bundle.main.url(forResource: name, withExtension: "svg"),
            let svgData = try? Data(contentsOf: templateURL)
        else {
            fatalError("no template found")
        }
        return Template(data: svgData, type: type)
    }
}

private extension String {
    static let placeholder = "–"
}
