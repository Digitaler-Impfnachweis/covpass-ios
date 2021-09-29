//
//  Template.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation

/// Helper structure to represent a SVG template plus meta information
public struct Template {
    enum TemplateType {
        case recovery, test, vaccination
    }

    let data: Data
    let type: TemplateType

    init(data: Data, type: TemplateType) {
        self.data = data
        self.type = type
    }

    init?(string: String, type: TemplateType) {
        guard let data = string.data(using: .utf8) else {
            return nil
        }
        self.init(data: data, type: type)
    }
}

// Used for PDF export
public extension DigitalGreenCertificate {
    /// The PDF template to match the current certificate
    ///
    /// A template for tests exists but is currently not used.
    var template: Template? {
        var templateName: String?
        var templateType: Template.TemplateType? = .none
        var country: String?

        if let v = v?.first {
            templateName = "VaccinationCertificateTemplate_v4.1"
            templateType = .vaccination
            country = v.co
        }
        if let r = r?.first {
            templateName = "RecoveryCertificateTemplate_v4.1"
            templateType = .recovery
            country = r.co
        }
        if let t = t?.first {
            templateName = "TestCertificateTemplate_v4.1"
            templateType = .test
            country = t.co
        }

        // Currently, only certificates issued in Germany are exportable.
        // Edge-case note: this check uses the country of vaccination/recovery.
        // If any issuer works cross-border, e.g. RKI in France, the export will be denied.
        guard let name = templateName, let type = templateType, country?.uppercased() == "DE" else {
            print("Certificate not valid for export")
            return nil
        }
        guard
            let templateURL = Bundle.module.url(forResource: name, withExtension: "svg"),
            let svgData = try? Data(contentsOf: templateURL)
        else {
            fatalError("no template found")
        }
        return Template(data: svgData, type: type)
    }
}
