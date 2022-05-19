//
//  RevocationInfoViewModelProtocol.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon

public protocol RevocationInfoViewModelProtocol {
    var buttonTitle: String { get }
    var delegate: ViewModelDelegate? { get set }
    var infoItems: [ListContentItem] { get }
    var isGeneratingPDF: Bool { get }
    var title: String { get }
    var enableCreatePDF: Bool { get }

    func cancel()
    func createPDF()
}
