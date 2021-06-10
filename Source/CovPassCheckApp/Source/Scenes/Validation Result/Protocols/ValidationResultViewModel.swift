//
//  ValidationResultViewModel.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import CovPassUI
import PromiseKit
import UIKit

struct Paragraph {
    var icon: UIImage?
    var title: String
    var subtitle: String
}

typealias ValidationResultViewModel = ValidationViewModel & CancellableViewModelProtocol

protocol ResultViewModelDelegate: AnyObject {
    func viewModelDidUpdate()
    func viewModelDidChange(_ newViewModel: ValidationResultViewModel)
}

protocol ValidationViewModel {
    var delegate: ResultViewModelDelegate? { get set }
    var icon: UIImage? { get }
    var resultTitle: String { get }
    var resultBody: String { get }
    var paragraphs: [Paragraph] { get }
    var info: String? { get }
    func scanNextCertifcate()
}
