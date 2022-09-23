//
//  MaskRequiredResultViewModelProtocol.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

protocol MaskRequiredResultViewModelProtocol {
    var title: String { get }
    var subtitle: String { get }
    var description: String { get }
    var reasonViewModels: [MaskRequiredReasonViewModelProtocol] { get }

    func close()
    func rescan()
}
