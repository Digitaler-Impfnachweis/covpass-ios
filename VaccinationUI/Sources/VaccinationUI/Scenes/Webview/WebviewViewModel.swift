//
//  File.swift
//  
//
//  Created by Sebastian Maschinski on 06.05.21.
//

import Foundation

public class WebviewViewModel: WebviewViewModelProtocol {
    // MARK: - Properties

    public let title: String?
    public let urlRequest: URLRequest

    // MARK: - Lifecycle

    public init(title: String? = nil, url: URL) {
        self.title = title
        urlRequest = URLRequest(url: url)
    }
}
