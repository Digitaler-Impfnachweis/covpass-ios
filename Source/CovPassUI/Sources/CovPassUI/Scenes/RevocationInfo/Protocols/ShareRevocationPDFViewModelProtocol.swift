//
//  ShareRevocationPDFViewModelProtocol.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation

protocol ShareRevocationPDFViewModelProtocol {
    var fileURL: URL { get }
    func handleActivityResult(completed: Bool, activityError: Error?)
}
