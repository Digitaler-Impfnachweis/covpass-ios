//
//  GProofViewModelProtocol.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import CovPassUI
import UIKit

protocol GProofViewModelProtocol {
    var title: String { get }
    var checkIdMessage: String { get }
    var footnote: String { get }
    var buttonScanNextTitle: String { get }
    var scanNextButtonIsHidden: Bool { get }
    var onlyOneIsScannedAndThisFailed: Bool { get }
    var buttonRetry: String { get }
    var isLoading: Bool { get set }
    var personStackIsHidden: Bool { get }
    var buttonRetryIsHidden: Bool { get }
    var buttonStartOver: String { get }
    var buttonStartOverIsHidden: Bool { get }
    var accessibilityResultAnnounce: String { get }
    var accessibilityResultAnnounceClose: String { get }
    var firstResultImage: UIImage { get }
    var firstResultTitle: String { get }
    var firstResultSubtitle: String? { get }
    var firstResultLinkImage: UIImage? { get }
    var firstResultFooterText: String? { get }
    var secondResultImage: UIImage { get }
    var secondResultTitle: String { get }
    var seconResultSubtitle: String? { get }
    var seconResultLinkImage: UIImage? { get }
    var seconResultFooterText: String? { get }
    var resultPersonIcon: UIImage { get }
    var resultPersonTitle: String? { get }
    var resultPersonSubtitle: String? { get }
    var resultPersonFooter: String? { get }
    var seconResultViewIsHidden: Bool { get }
    var pageFooterIsHidden: Bool { get }
    var someIsFailed: Bool  { get }
    var firstIsFailedTechnicalReason: Bool { get }
    var secondIsFailedTechnicalReason: Bool { get }
    var areBothScanned: Bool { get }
    var delegate: ViewModelDelegate? { get set }
    var firstResult: GProofValidationResult?  { get set }
    var secondResult: GProofValidationResult?  { get set }
    func scanNext()
    func retry()
    func startover()
    func cancel()
    func showSecondCardResult()
    func showFirstCardResult()
}
