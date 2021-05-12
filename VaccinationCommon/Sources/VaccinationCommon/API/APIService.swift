//
//  APIService.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

import Foundation
import PromiseKit
import SwiftCBOR

public struct APIService: APIServiceProtocol {
    private let url: String
    private let contentType: String = "application/cbor+base45"

    private let coder = Base45Coder()
    private let sessionDelegate: URLSessionDelegate

    public init(sessionDelegate: URLSessionDelegate, url: String) {
        self.sessionDelegate = sessionDelegate
        self.url = url
    }

    public func reissue(_ vaccinationQRCode: String) -> Promise<String> {
        return Promise { seal in
            let code = vaccinationQRCode.stripPrefix()
            let base45Decoded = try coder.decode(code)
            guard let decompressedPayload = Compression.decompress(Data(base45Decoded)) else {
                seal.reject(APIError.compressionFailed)
                return
            }

            guard let requestUrl = URL(string: url) else {
                seal.reject(APIError.invalidUrl)
                return
            }
            var request = URLRequest(url: requestUrl)
            request.httpMethod = "POST"
            request.httpBody = decompressedPayload
            request.addValue(contentType, forHTTPHeaderField: "Accept")

            let session = URLSession(configuration: URLSessionConfiguration.ephemeral,
                                     delegate: sessionDelegate,
                                     delegateQueue: nil)

            session.dataTask(with: request) { data, response, error in
                if let error = error {
                    if let error = error as NSError?, error.code == NSURLErrorCancelled {
                        seal.reject(APIError.requestCancelled)
                        return
                    }
                    if let error = error as? URLError, error.isCancelled {
                        seal.reject(APIError.requestCancelled)
                        return
                    }
                    seal.reject(error)
                    return
                }
                guard let response = response as? HTTPURLResponse else {
                    seal.reject(APIError.invalidReponse)
                    return
                }
                guard (200 ... 299).contains(response.statusCode) else {
                    print(String(data: data ?? Data(), encoding: .utf8) ?? "")
                    seal.reject(APIError.invalidReponse)
                    return
                }

                guard let data = data, let validationCertificate = String(data: data, encoding: .utf8) else {
                    seal.reject(APIError.invalidReponse)
                    return
                }

                seal.fulfill(validationCertificate)
            }.resume()
        }
    }
}
