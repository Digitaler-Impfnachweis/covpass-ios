//
//  APIService.swift
//  
//
//  Copyright © 2021 IBM. All rights reserved.
//

import Foundation
import PromiseKit
import SwiftCBOR

public protocol APIServiceProtocol {
    func reissue(_ vaccinationQRCode: String) -> Promise<String>
}

public struct APIService: APIServiceProtocol {

    // TODO get URL from config
    private let url: String = "https://api.recertify.demo.ubirch.com/api/certify/v2/reissue/cbor"

    // TODO rename Encoder to Coder because an encoder does not decode
    private let encoder = Base45Encoder()

    public init() {}

    public func reissue(_ vaccinationQRCode: String) -> Promise<String> {
        return Promise { seal in
            let base45Decoded = try encoder.decode(vaccinationQRCode)
            guard let decompressedPayload = Compression.decompress(Data(base45Decoded)) else {
                seal.reject(ApplicationError.unknownError)
                return
            }

            guard let requestUrl = URL(string: url) else {
                seal.reject(ApplicationError.unknownError)
                return
            }
            var request = URLRequest(url: requestUrl)
            request.httpMethod = "POST"
            request.httpBody = decompressedPayload
            request.addValue("application/cbor+base45", forHTTPHeaderField: "Content-Type")

            URLSession.shared.dataTask(with: request) { (data, response, error) in
                // Check for Error
                if let error = error {
                    seal.reject(error)
                    return
                }
                guard let response = response as? HTTPURLResponse else {
                    seal.reject(ApplicationError.unknownError)
                    return
                }
                guard (200...299).contains(response.statusCode) else {
                    print(String(data: data ?? Data(), encoding: .utf8) ?? "")
                    seal.reject(ApplicationError.unknownError)
                    return
                }

                guard let data = data, let validationCertificate = String(data: data, encoding: .utf8) else {
                    seal.reject(ApplicationError.unknownError)
                    return
                }

                seal.fulfill(validationCertificate)
            }.resume()
        }
    }
}
