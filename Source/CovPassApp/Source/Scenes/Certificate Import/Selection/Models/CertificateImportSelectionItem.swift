//
//  CertificateImportSelectionItem.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon

class CertificateImportSelectionItem {
    let title: String
    let subtitle: String
    let additionalLines: [String]
    let token: ExtendedCBORWebToken
    var selected: Bool = false

    init(title: String, subtitle: String, additionalLines: [String], token: ExtendedCBORWebToken) {
        self.title = title
        self.subtitle = subtitle
        self.additionalLines = additionalLines
        self.token = token
    }
}
