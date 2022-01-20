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
    var buttonScanTest: String { get }
    var buttonScanTestIsHidden: Bool { get }
    var onlyOneIsScannedAndThisFailed: Bool { get }
    var buttonRetry: String { get }
    var buttonRetryIsHidden: Bool { get }
    var buttonStartOver: String { get }
    var buttonStartOverIsHidden: Bool { get }
    var buttonScan2G: String { get }
    var buttonScan2GIsHidden: Bool { get }
    var accessibilityResultAnnounce: String { get }
    var accessibilityResultAnnounceClose: String { get }
    var resultGProofImage: UIImage { get }
    var resultGProofTitle: String { get }
    var resultGProofSubtitle: String? { get }
    var resultGProofLinkImage: UIImage? { get }
    var resultGProofFooter: String? { get }
    var resultTestImage: UIImage { get }
    var resultTestTitle: String { get }
    var resultTestSubtitle: String? { get }
    var resultTestLinkImage: UIImage? { get }
    var resultTestFooter: String? { get }
    var resultPersonIcon: UIImage { get }
    var resultPersonTitle: String? { get }
    var resultPersonSubtitle: String? { get }
    var resultPersonFooter: String? { get }
    var someIsFailed: Bool  { get }
    var areBothScanned: Bool { get }
    var delegate: ViewModelDelegate? { get set }
    var gProofResultViewModel: ValidationResultViewModel?  { get set }
    var testResultViewModel: ValidationResultViewModel?  { get set }
    func scanTest()
    func scan2GProof()
    func retry()
    func startover()
    func cancel()
    func showResultTestProof()
    func showResultGProof()
}
