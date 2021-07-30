//
//  CertificateViewController.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import UIKit

struct SVGPDFExporter {

    typealias Template = String

    private lazy var dateFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate]
        return formatter
    }()

    static func fill(template: Template, with token: ExtendedCBORWebToken) -> Data? {

        let certificate = token.vaccinationCertificate.hcert.dgc
        let latestVacc = certificate.v?.sorted(by: { $0.dn > $1.dn }).first

        var template = template
        template = template.replacingOccurrences(of: "$nam", with: certificate.nam.fullName)
        template = template.replacingOccurrences(of: "$dob", with: certificate.dobString ?? .placeholder)
        template = template.replacingOccurrences(of: "$tg", with: latestVacc?.tg ?? .placeholder)
        template = template.replacingOccurrences(of: "$ci", with: certificate.uvci)
        // QR code: already base64 encoded
        template = template.replacingOccurrences(of: "$qr", with: token.vaccinationQRCodeData)

        // individual fields for specific certificate types
        #warning("date formatters!")
        /* === recovery ===*/
        // date of first positive test result
        template = template.replacingOccurrences(of: "$fr", with: certificate.latestRecovery?.fr.debugDescription ?? .placeholder)
        // valid from
        template = template.replacingOccurrences(of: "$df", with: certificate.r?.first?.df.debugDescription ?? .placeholder)
        // valid until
        template = template.replacingOccurrences(of: "$du", with: certificate.r?.first?.du.debugDescription ?? .placeholder)

        /* === test ===*/
        // test type
        template = template.replacingOccurrences(of: "$tt", with: certificate.t?.first?.tt ?? .placeholder)
        // test name
        template = template.replacingOccurrences(of: "$nm", with: certificate.t?.first?.nm ?? .placeholder)
        // test manufacturer
        template = template.replacingOccurrences(of: "$ma", with: certificate.t?.first?.ma ?? .placeholder)
        // sample collection
        template = template.replacingOccurrences(of: "$sc", with: certificate.t?.first?.sc.debugDescription ?? .placeholder)
        // date test result
        //template = template.replacingOccurrences(of: "$dr", with: certificate.t?.first?..debugDescription ?? .placeholder)
        // test result
        template = template.replacingOccurrences(of: "$tr", with: certificate.t?.first?.tr ?? .placeholder)
        // testing center
        template = template.replacingOccurrences(of: "$tc", with: certificate.t?.first?.tc ?? .placeholder)
        // country
        template = template.replacingOccurrences(of: "$co", with: certificate.t?.first?.co ?? .placeholder)
        // certificate issue
        template = template.replacingOccurrences(of: "$is", with: certificate.t?.first?.is ?? .placeholder)

        /* === vaccination ===*/
        // disease of agent targeted
        template = template.replacingOccurrences(of: "$tg", with: certificate.v?.first?.tg ?? .placeholder)
        // vaccine
        template = template.replacingOccurrences(of: "$vp", with: certificate.v?.first?.vp ?? .placeholder)
        // vaccine product name
        template = template.replacingOccurrences(of: "$mp", with: certificate.v?.first?.mp ?? .placeholder)
        // marketing authorization
        template = template.replacingOccurrences(of: "$ma", with: certificate.v?.first?.ma ?? .placeholder)
        // vaccination x of y
        template = template.replacingOccurrences(of: "$dn", with: "\(certificate.v?.first?.dn ?? 0)") // FIXME: optionals, localization
        template = template.replacingOccurrences(of: "$sd", with: "\(certificate.v?.first?.sd ?? 0)")
        // date vaccination
        template = template.replacingOccurrences(of: "$dt", with: certificate.v?.first?.dt.debugDescription ?? .placeholder)
        // country
        template = template.replacingOccurrences(of: "$co", with: certificate.v?.first?.co ?? .placeholder)
        // certificate issue
        template = template.replacingOccurrences(of: "$is", with: certificate.v?.first?.is ?? .placeholder)


        assert(template.firstIndex(of: "$") == nil, "missed one placeholder!") // TODO: write test for this!
        return template.data(using: .utf8)
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
