//
//  DifferentPersonViewModelProtocol.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import CovPassUI
import UIKit

protocol DifferentPersonViewModelProtocol: CountdownViewModel {
    var title: String { get }
    var subtitle: String { get }
    var footerHeadline: String { get }
    var footerText: String { get }
    var footerLinkText: String { get }
    var rescanButtonTitle: String { get }
    var cancelButtonTitle: String { get }
    var personViewModels: [PersonViewModel] { get }
    var ignoringIsHidden: Bool { get }
    var thirdCardIsHidden: Bool { get }
    var delegate: ViewModelDelegate? { get set }
    func rescan()
    func ignoreButton()
    func close()
}
