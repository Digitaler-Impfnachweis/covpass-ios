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

typealias ValidationResultViewModel = ValidationViewModel & BaseViewModel & CancellableViewModelProtocol

struct Paragraph {
    var icon: UIImage?
    var title: String
    var subtitle: String
}

protocol ValidationViewModel {
    var icon: UIImage? { get }
    var resultTitle: String { get }
    var resultBody: String { get }
    var paragraphs: [Paragraph] { get }
    var info: String? { get }
//    var nameTitle: String? { get }
//    var nameBody: String? { get }
//    var errorTitle: String? { get }
//    var errorBody: String? { get }
//    var nameIcon: UIImage? { get }
//    var errorIcon: UIImage? { get }

    func scanNextCertifcate()
}
