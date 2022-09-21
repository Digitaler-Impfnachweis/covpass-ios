//
//  NewRegulationsAnnouncementViewModelProtocol.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import UIKit

public protocol NewRegulationsAnnouncementViewModelProtocol {
    var header: String { get }
    var illustration: UIImage { get }
    var copyText1: String { get }
    var subtitle: String { get }
    var copyText2: String { get }
    var buttonTitle: String { get }

    func close()
}
