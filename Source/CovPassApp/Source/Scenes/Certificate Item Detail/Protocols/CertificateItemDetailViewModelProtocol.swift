//
//  CertificateItemDetailViewModelProtocol.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import CovPassUI
import UIKit

protocol CertificateItemDetailViewModelProtocol {
    var title: String { get }
    var headline: String { get }
    var revocationText: String { get }
    var hideQRCodeButtons: Bool { get }
    var items: [ListContentItem] { get }
    var canExportToPDF: Bool { get }
    var vaasResultToken: VAASValidaitonResultToken? { get }
    var hasValidationResult: Bool { get }
    var expirationHintButtonIsHidden: Bool? { get }
    var expirationHintIsHidden: Bool { get }
    var expirationHintIcon: UIImage? { get }
    var expirationHintBackgroundColor: UIColor? { get }
    var expirationHintBorderColor: UIColor? { get }
    var expirationHintTitle: String? { get }
    var expirationHintButtonTitle: String? { get }
    var expirationHintBodyText: String? { get }
    func showQRCode()
    func startPDFExport()
    func deleteCertificate()
    func triggerVaccinationExpiryReissue()
    func triggerRecoveryExpiryReissue(index: Int)
}
