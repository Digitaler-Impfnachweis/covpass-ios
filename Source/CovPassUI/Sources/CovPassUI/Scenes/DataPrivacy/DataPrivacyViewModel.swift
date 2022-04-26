//
//  AnnouncementViewModel.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import PromiseKit
import UIKit

public class DataPrivacyViewModel: BaseViewModel, CancellableViewModelProtocol {
    // MARK: - Properties
    
    weak public var delegate: ViewModelDelegate?
    private let router: DataPrivacyRouter
    private let resolver: Resolver<Void>
    let webViewRequest: URLRequest
    
    // MARK: - Lifecycle
    
    public init(router: DataPrivacyRouter,
         resolvable: Resolver<Void>,
         privacyURL: URL
    ) {
        self.router = router
        resolver = resolvable
        webViewRequest = URLRequest(url: privacyURL)
    }
    
    func done() {
        resolver.fulfill_()
    }
    
    public func cancel() {
        resolver.cancel()
    }
}
