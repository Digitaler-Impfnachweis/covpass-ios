//
//  AnnouncementViewModel.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassUI
import LocalAuthentication
import PromiseKit
import UIKit

class AnnouncementViewModel: BaseViewModel, CancellableViewModelProtocol {
    // MARK: - Properties

    weak var delegate: ViewModelDelegate?
    let router: AnnouncementRouter
    let resolver: Resolver<Void>

    var webViewRequest: URLRequest? {
        guard let url = Bundle.commonBundle.url(forResource: Locale.current.isGerman() ? "announcements_de" : "announcements_en", withExtension: "html") else { return nil }
        return URLRequest(url: url)
    }

    // MARK: - Lifecycle

    init(
        router: AnnouncementRouter,
        resolvable: Resolver<Void>
    ) {
        self.router = router
        resolver = resolvable
    }

    func done() {
        resolver.fulfill_()
    }

    func cancel() {
        resolver.cancel()
    }
}
