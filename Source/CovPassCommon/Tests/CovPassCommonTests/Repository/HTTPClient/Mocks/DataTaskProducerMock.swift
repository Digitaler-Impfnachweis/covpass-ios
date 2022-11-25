//
//  File.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassCommon
import Foundation

class DataTaskProducerMock: DataTaskProducerProtocol {
    var data: Data? = Data()
    var error: Error?
    var response: URLResponse? = HTTPURLResponse(
        url: FileManager.default.temporaryDirectory,
        statusCode: 200,
        httpVersion: nil,
        headerFields: nil
    )

    func dataTask(with _: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        let task = URLSessionDataTaskMock()
        task.data = data
        task.mockError = error
        task.mockResponse = response
        task.completion = completionHandler

        return task
    }
}

class URLSessionDataTaskMock: URLSessionDataTask {
    var data: Data?
    var mockError: Error?
    var mockResponse: URLResponse?
    var completion: ((Data?, URLResponse?, Error?) -> Void)?

    override func resume() {
        completion?(data, mockResponse, mockError)
    }
}
