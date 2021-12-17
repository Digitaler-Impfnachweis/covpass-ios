//
//  ScanCountWarningViewModelProtocol.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import UIKit

protocol ScanCountWarningViewModelProtocol {
    var headerImage: UIImage { get }
    var title: String { get }
    var description: String { get }
    var acceptButtonText: String { get }
    var cancelButtonText: String { get }
    var accOpenPage: String { get }
    var accImageDescription: String { get }
    func continueProcess()
    func cancelProcess()
    func routeToSafari(url: URL)
}
