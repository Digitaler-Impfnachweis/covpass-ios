//
//  GProofDifferentPersonViewModelProtocol.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassUI
import CovPassCommon
import UIKit

protocol GProofDifferentPersonViewModelProtocol {
    var title: String { get }
    var subtitle: String { get }
    var gProofCardImage: UIImage { get }
    var testProofCardImage: UIImage { get }
    var gProofTitle: String { get }
    var testProofTitle: String { get }
    var footerHeadline: String { get }
    var footerText: String { get }
    var footerLinkText: String { get }
    var retryButton: String { get }
    var startOverButton: String { get }
    var gProofName: String { get }
    var gProofNameTranslittered: String { get }
    var gProofDateOfBirth: String { get }
    var testProofName: String { get }
    var testProofNameTranslittered: String { get }
    var testProofDateOfBirth: String { get }

    var gProofToken: CBORWebToken { get set }
    var testProofToken: CBORWebToken { get set }
    var delegate: ViewModelDelegate? { get set }
    var isDateOfBirthDifferent: Bool { get }
    func startover()
    func retry()
    func cancel()
}
