//
//  WhatsNewSettingsViewModelProtocol.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation

protocol WhatsNewSettingsViewModelProtocol {
    var accessibilityAnnouncementOpen: String { get }
    var accessibilityAnnouncementClose: String { get }
    var header: String { get }
    var description: String { get }
    var switchTitle: String { get }
    var disableWhatsNew: Bool { get set }
    var whatsNewURLRequest: URLRequest { get }
}
