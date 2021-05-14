//
//  AppInformationViewModelProtocol.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation

public protocol AppInformationViewModelProtocol {
    var router: AppInformationRouterProtocol { get }
    var title: String { get }
    var descriptionText: String { get }
    var appVersionText: String { get }
    var entries: [AppInformationEntry] { get }

    func showSceneForEntry(_ entry: AppInformationEntry)
}
