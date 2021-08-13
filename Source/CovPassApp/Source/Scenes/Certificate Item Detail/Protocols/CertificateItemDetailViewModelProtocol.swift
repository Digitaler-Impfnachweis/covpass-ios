//
//  CertificateItemDetailViewModelProtocol.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassUI
import UIKit

protocol CertificateItemDetailViewModelProtocol {
    var title: String { get }
    var showSubtitle: Bool { get }
    var headline: String { get }
    var isExpired: Bool { get }
    var expiresSoonDate: Date? { get }
    var isInvalid: Bool { get }
    var items: [ContentItem] { get }
    var canExportToPDF: Bool { get }
    func showQRCode()
    func startPDFExport()
    func deleteCertificate()
}

/// Helper-struct to define content
struct ContentItem {
    let label: String
    let value: String
    let accessibilityLabel: String?
    let accessibilityIdentifier: String?

    init(_ label: String, _ value: String, _ accessibilityLabel: String? = nil, _ accessibilityIdentifier: String? = nil) {
        self.init(label: label, value: value, accessibilityLabel: accessibilityLabel, accessibilityIdentifier: accessibilityIdentifier)
    }

    init(label: String, value: String, accessibilityLabel: String? = nil, accessibilityIdentifier: String? = nil) {
        self.label = label
        self.value = value
        self.accessibilityLabel = accessibilityLabel ?? "\(label)\n\(value)" // break adds a pause
        self.accessibilityIdentifier = accessibilityIdentifier
    }
}
