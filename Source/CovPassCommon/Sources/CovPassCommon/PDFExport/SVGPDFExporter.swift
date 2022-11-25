//
//  SVGPDFExporter.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation

/// Certificate PDF Exporter for SVG templates.
public final class SVGPDFExporter: SVGPDFExportProtocol {
    public enum ExportError: Error {
        case invalidTemplate
    }

    /// Date formated as `yyyy-MM-dd`.
    private lazy var dateFormatter = DateUtils.isoDateFormatter

    private let converter: SVGToPDFConverterProtocol

    public init(converter: SVGToPDFConverterProtocol) {
        self.converter = converter
    }

    // MARK: - SVGPDFExportProtocol

    public func fill(template: Template, with token: ExtendedCBORWebToken) throws -> SVGData? {
        let certificate = token.vaccinationCertificate.hcert.dgc
        guard
            let data = certificate.template?.data,
            var svg = String(data: data, encoding: .utf8)
        else {
            assertionFailure()
            return nil
        }

        // Common fields
        svg = svg.replacingOccurrences(of: "$nam", with: certificate.nam.fullNameReverse.sanitizedXMLString)
        svg = svg.replacingOccurrences(of: "$dob", with: certificate.dobString?.sanitizedXMLString ?? "XXXX-XX-XX")
        svg = svg.replacingOccurrences(of: "$ci", with: certificate.uvci.stripUVCIPrefix().sanitizedXMLString)

        // QR code
        let qr = token.vaccinationQRCodeData.generateQRCode()
        svg = svg.replacingOccurrences(of: "$qr", with: qr?.pngData()?.base64EncodedString() ?? .placeholder)

        switch template.type {
        case .recovery:
            guard let recovery = certificate.latestRecovery else {
                throw ExportError.invalidTemplate
            }
            // disease of agent targeted
            svg = svg.replacingOccurrences(of: "$tg", with: recovery.tgDisplayName.sanitizedXMLString)
            // date of first positive test result
            svg = svg.replacingOccurrences(of: "$fr", with: dateFormatter.string(from: recovery.fr))
            // valid from
            svg = svg.replacingOccurrences(of: "$df", with: dateFormatter.string(from: recovery.df))
            // valid until
            svg = svg.replacingOccurrences(of: "$du", with: dateFormatter.string(from: recovery.du))
            // country
            svg = svg.replacingOccurrences(of: "$co", with: recovery.co.sanitizedXMLString)
            // certificate issue
            svg = svg.replacingOccurrences(of: "$is", with: recovery.is.sanitizedXMLString)
        case .test:
            guard let test = certificate.latestTest else {
                throw ExportError.invalidTemplate
            }
            // disease of agent targeted
            svg = svg.replacingOccurrences(of: "$tg", with: test.tgDisplayName.sanitizedXMLString)
            // test type
            svg = svg.replacingOccurrences(of: "$tt", with: test.ttDisplayName.sanitizedXMLString)
            // test name
            svg = svg.replacingOccurrences(of: "$nm", with: test.nm?.sanitizedXMLString ?? .placeholder)
            // test manufacturer
            svg = svg.replacingOccurrences(of: "$ma", with: test.maDisplayName?.sanitizedXMLString ?? .placeholder)
            // sample collection
            svg = svg.replacingOccurrences(of: "$sc", with: DateUtils.isoDateTimeFormatter.string(from: test.sc))
            // test result
            svg = svg.replacingOccurrences(of: "$tr", with: test.trDisplayName.sanitizedXMLString)
            // testing center
            svg = svg.replacingOccurrences(of: "$tc", with: test.tc?.sanitizedXMLString ?? .placeholder)
            // country
            svg = svg.replacingOccurrences(of: "$co", with: test.co.sanitizedXMLString)
            // certificate issue
            svg = svg.replacingOccurrences(of: "$is", with: test.is.sanitizedXMLString)
        case .vaccination:
            guard let vaccination = certificate.latestVaccination else {
                throw ExportError.invalidTemplate
            }
            // disease of agent targeted
            svg = svg.replacingOccurrences(of: "$tg", with: vaccination.tgDisplayName.sanitizedXMLString)
            // vaccine
            svg = svg.replacingOccurrences(of: "$vp", with: vaccination.vpDisplayName.sanitizedXMLString)
            // vaccine product name
            svg = svg.replacingOccurrences(of: "$mp", with: vaccination.mpDisplayName.sanitizedXMLString)
            // marketing authorization
            svg = svg.replacingOccurrences(of: "$ma", with: vaccination.maDisplayName.sanitizedXMLString)
            // vaccination x of y - number format is not localized!
            svg = svg.replacingOccurrences(of: "$dn", with: vaccination.dn.description)
            svg = svg.replacingOccurrences(of: "$sd", with: vaccination.sd.description)
            // date vaccination
            svg = svg.replacingOccurrences(of: "$dt", with: dateFormatter.string(from: vaccination.dt))
            // country
            svg = svg.replacingOccurrences(of: "$co", with: vaccination.co.sanitizedXMLString)
            // certificate issue
            svg = svg.replacingOccurrences(of: "$is", with: vaccination.is.sanitizedXMLString)
        }

        #if DEBUG
            let pattern = #"\>\$\w+\<"#
            let regex = try! NSRegularExpression(pattern: pattern)
            let range = NSRange(location: 0, length: svg.utf16.count)
            if let match = regex.firstMatch(in: svg, options: [], range: range) {
                let nsString = svg as NSString
                let matchString = nsString.substring(with: match.range) as String
                assertionFailure("missed one placeholder: \(matchString)")
            }
        #endif

        return svg.data(using: .utf8)
    }

    public func export(_ data: SVGData, completion: ExportHandler?) {
        converter
            .convert(data)
            .done { pdfDocument in
                completion?(pdfDocument)
            }
            .catch { _ in
                completion?(nil)
            }
    }
}

// MARK: – Helper Extensions

extension DigitalGreenCertificate {
    /// Checks if the given certificate can be technically exported, i.e. has a PDF-template available
    ///
    /// **Important:** This does NOT check for any business rules or expiration dates!
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

private extension String {
    static let placeholder = "–"
}
