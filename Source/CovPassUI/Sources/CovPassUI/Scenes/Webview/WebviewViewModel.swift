//
//  WebviewViewModel.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation

public class WebviewViewModel: WebviewViewModelProtocol {

    
    // MARK: - Properties

    public let title: String?
    public let urlRequest: URLRequest
    public var closeButtonShown: Bool
    public var isToolbarShown: Bool
    public var openingAnnounce: String
    public var closingAnnounce: String
    
    // MARK: - Lifecycle

    public init(title: String? = nil,
                url: URL,
                closeButtonShown: Bool,
                isToolbarShown: Bool,
                openingAnnounce: String,
                closingAnnounce: String) {
        self.title = title
        self.closeButtonShown = closeButtonShown
        self.isToolbarShown = isToolbarShown
        self.openingAnnounce = openingAnnounce
        self.closingAnnounce = closingAnnounce
        urlRequest = URLRequest(url: url)
    }
}
