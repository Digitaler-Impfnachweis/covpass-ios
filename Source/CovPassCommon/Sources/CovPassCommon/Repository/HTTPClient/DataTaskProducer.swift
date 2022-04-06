//
//  DataTaskProducer.swift
//  
//
//  Created by Thomas Kuleßa on 21.03.22.
//

import Foundation

public struct DataTaskProducer: DataTaskProducerProtocol {
    private let urlSession: URLSession

    public init(urlSession: URLSession) {
        self.urlSession = urlSession
    }

    public func dataTask(
        with request: URLRequest,
        completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void
    ) -> URLSessionDataTask {
        urlSession.dataTask(with: request, completionHandler: completionHandler)
    }
}
