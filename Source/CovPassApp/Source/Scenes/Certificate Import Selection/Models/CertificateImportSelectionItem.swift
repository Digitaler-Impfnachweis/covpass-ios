//
//  CertificateImportSelectionItem.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

class CertificateImportSelectionItem {
    let title: String
    let subtitle: String
    let additionalLines: [String]
    var selected: Bool = false

    init(title: String, subtitle: String, additionalLines: [String]) {
        self.title = title
        self.subtitle = subtitle
        self.additionalLines = additionalLines
    }
}

