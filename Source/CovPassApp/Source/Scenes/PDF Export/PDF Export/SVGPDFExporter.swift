//
//  SVGPDFExporter.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import UIKit

final class SVGPDFExporter {

    /// Date formated as `yyyy-MM-dd`.
    private lazy var dateFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate]
        return formatter
    }()

    func fill(template: Template, with token: ExtendedCBORWebToken) -> Data? {
        let certificate = token.vaccinationCertificate.hcert.dgc

        var svg = template.svgString

        // Common fields
        svg = svg.replacingOccurrences(of: "$nam", with: certificate.nam.fullName)
        svg = svg.replacingOccurrences(of: "$dob", with: certificate.dobString ?? .placeholder)
        svg = svg.replacingOccurrences(of: "$ci", with: certificate.uvci)
        // QR code: already base64 encoded
        svg = svg.replacingOccurrences(of: "$qr", with: token.vaccinationQRCodeData)

        switch template.type {
        case .recovery:
            guard let recovery = certificate.latestRecovery else { return nil }

            // date of first positive test result
            svg = svg.replacingOccurrences(of: "$fr", with: dateFormatter.string(from: recovery.fr))
            // valid from
            svg = svg.replacingOccurrences(of: "$df", with: dateFormatter.string(from: recovery.df))
            // valid until
            svg = svg.replacingOccurrences(of: "$du", with: dateFormatter.string(from: recovery.du))
        case.test:
            guard let test = certificate.latestTest else { return nil }

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
            guard let vaccination = certificate.latestVaccination else { return nil }

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

        assert(svg.firstIndex(of: "$") == nil, "missed one placeholder!") // TODO: write test for this!
        return svg.data(using: .utf8)
    }
}

extension ExtendedCBORWebToken {
    /// Checks if a certificate in the given token can be exported to PDF
    ///
    /// If multiple certificates are present the priotization is as follows (most to least important):
    /// 1. vaccination
    /// 2. test
    /// 3. recovery
    var canExportToPDF: Bool {
        vaccinationCertificate.hcert.dgc.templateName != nil
    }
}

extension DigitalGreenCertificate {
    /// Checks if the given certificate can be exported
    var canExportToPDF: Bool {
        templateName != nil
    }

    var latestRecovery: Recovery? {
        r?.filter({ $0.isValid}).sorted(by: { $0.df > $1.df }).first
    }

    var latestTest: Test? {
        t?.filter({ $0.isValid}).sorted(by: { $0.sc > $1.sc }).first
    }

    var latestVaccination: Vaccination? {
        v?.filter({ $0.validMp }).sorted(by: { $0.dt > $1.dt }).first
    }
}

private extension DigitalGreenCertificate {
    /// The template filename for the given certificate
    var templateName: String? {
        // ordered list (most to least important): [v]accination, [t]est, [r]ecery
        if let _ = v?.first { return "VaccinationCertificateTemplate_v2_2021-06-03_02_DEMO" }
        if let _ = t?.first { return "TestCertificateTemplate_v2_2021-06-03_02_DEMO" }
        if let _ = r?.first { return "RecoveryCertificateTemplate_v2_2021-06-03_02_DEMO" }
        return nil
    }
}

private extension String {
    static let placeholder = "–"
}
