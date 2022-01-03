//
//  AnnouncementViewModel.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import PromiseKit
import UIKit

class DataPrivacyViewModel: BaseViewModel, CancellableViewModelProtocol {
    // MARK: - Properties
    
    weak var delegate: ViewModelDelegate?
    let router: DataPrivacyRouter
    let resolver: Resolver<Void>
    
    var webViewRequest: URLRequest? {
        guard let url =  Bundle.main.url(forResource: Locale.current.isGerman() ? "privacy-covpass-de" : "privacy-covpass-en", withExtension: "html") else { return nil }
        return URLRequest(url: url)
    }
    
    // MARK: - Lifecycle
    
    init(router: DataPrivacyRouter,
         resolvable: Resolver<Void>) {
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
