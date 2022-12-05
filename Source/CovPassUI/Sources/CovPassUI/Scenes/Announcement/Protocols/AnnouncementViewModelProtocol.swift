//
//  AnnouncementViewModelProtocol.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation

protocol AnnouncementViewModelProtocol: CancellableViewModelProtocol {
    var whatsNewURL: URL { get }
    var checkboxTitle: String { get }
    var checkboxDescription: String { get }
    var checkboxAccessibilityValue: String { get }
    var okButtonTitle: String { get }
    var disableWhatsNew: Bool { get set }

    func done()
}
