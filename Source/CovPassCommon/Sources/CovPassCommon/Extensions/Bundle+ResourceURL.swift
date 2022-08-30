//
//  Bundle+ResourceURL.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation

public extension Bundle {
    var germanAnnouncementsURL: URL? {
        url(forResource: "announcements_de", withExtension: "html")
    }

    var englishAnnouncementsURL: URL? {
        url(forResource: "announcements_en", withExtension: "html")
    }
}
