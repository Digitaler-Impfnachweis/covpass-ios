//
//  DataTaskProducerProtocol.swift
//  
//
//  Created by Thomas Kuleßa on 21.03.22.
//

import Foundation

public protocol DataTaskProducerProtocol {
    func dataTask(
        with request: URLRequest,
        completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void
    ) -> URLSessionDataTask
}
