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
        var name: String? = nil
        var type: Template.TemplateType? = .none
        if let _ = v?.first {
            name = "VaccinationCertificateTemplate_v4.1"
            type = .vaccination
        }
        if let _ = r?.first {
            name = "RecoveryCertificateTemplate_v4.1"
            type = .recovery
        }

        guard let name = name, let type = type else {
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
