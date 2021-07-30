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

    static func fill(template: Template, with token: ExtendedCBORWebToken) -> Data? {

        let certificate = token.vaccinationCertificate.hcert.dgc
        let latestVacc = certificate.v?.sorted(by: { $0.dn > $1.dn }).first

        var template = template
        template = template.replacingOccurrences(of: "$nam", with: certificate.nam.fullName)
        template = template.replacingOccurrences(of: "$dob", with: certificate.dobString ?? .placeholder)

        template = template.replacingOccurrences(of: "$tg", with: latestVacc?.tg ?? .placeholder)
        template = template.replacingOccurrences(of: "$fr", with: "date of first positive test result" /* latestVacc?.fullImmunizationValidFrom */)
        template = template.replacingOccurrences(of: "$df", with: "valid from" /* certificate.r?.first?.df */)
        template = template.replacingOccurrences(of: "$du", with: "2021-99-99")

        template = template.replacingOccurrences(of: "$ci", with: certificate.uvci)

        #warning("cover all types of certificates")

        // already base64 encoded
        template = template.replacingOccurrences(of: "$qr", with: token.vaccinationQRCodeData)

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
