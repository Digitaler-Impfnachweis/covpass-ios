//
//  CertificateItemDetailViewModelProtocol.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassUI
import UIKit
import CovPassCommon

protocol CertificateItemDetailViewModelProtocol {
    var title: String { get }
    var headline: String { get }
    var revocationText: String { get }
    var isRevoked: Bool { get }
    var hideQRCodeButtons: Bool { get }
    var isExpired: Bool { get }
    var expiresSoonDate: Date? { get }
    var isInvalid: Bool { get }
    var items: [ListContentItem] { get }
    var canExportToPDF: Bool { get }
    var vaasResultToken: VAASValidaitonResultToken? { get }
    var hasValidationResult: Bool { get }
    var isGerman: Bool { get }
    func showQRCode()
    func startPDFExport()
    func deleteCertificate()
}
