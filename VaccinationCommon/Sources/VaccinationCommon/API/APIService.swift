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
    // TODO: get URL from config
    private let url: String = "https://api.recertify.demo.ubirch.com/api/certify/v2/reissue/cbor"
    private let contentType: String = "application/cbor+base45"

    // TODO: rename Encoder to Coder because an encoder does not decode
    private let encoder = Base45Encoder()
    private let sessionDelegate: URLSessionDelegate

    public init(sessionDelegate: URLSessionDelegate = APIServiceDelegate(certFileName: "rsa-certify.demo.ubirch.com")) {
        self.sessionDelegate = sessionDelegate
    }

    public func reissue(_ vaccinationQRCode: String) -> Promise<String> {
        return Promise { seal in
            let code = vaccinationQRCode.stripPrefix()
            let base45Decoded = try encoder.decode(code)
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
            request.addValue(contentType, forHTTPHeaderField: "Accept")

            let session = URLSession(configuration: URLSessionConfiguration.ephemeral,
                                     delegate: sessionDelegate,
                                     delegateQueue: nil)

            session.dataTask(with: request) { data, response, error in
                // Check for Error
                if let error = error {
                    seal.reject(error)
                    return
                }
                guard let response = response as? HTTPURLResponse else {
                    seal.reject(ApplicationError.unknownError)
                    return
                }
                guard (200 ... 299).contains(response.statusCode) else {
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

public class APIServiceDelegate: NSObject, URLSessionDelegate {
    private var certFileName: String

    public init(certFileName: String) {
        self.certFileName = certFileName
    }

    public func urlSession(_: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
            if let serverTrust = challenge.protectionSpace.serverTrust {
                var result = SecTrustResultType.invalid
                let isTrustedServer = SecTrustEvaluate(serverTrust, &result)

                if errSecSuccess == isTrustedServer {
                    guard let serverCertificate = SecTrustGetCertificateAtIndex(serverTrust, 0) else {
                        completionHandler(URLSession.AuthChallengeDisposition.cancelAuthenticationChallenge, nil)
                        return
                    }
                    let serverCertificateData = SecCertificateCopyData(serverCertificate)
                    let size = CFDataGetLength(serverCertificateData)
                    if let dataBytes = CFDataGetBytePtr(serverCertificateData) {
                        let cert1 = NSData(bytes: dataBytes, length: size)
                        if let cerFilePath = Bundle.module.url(forResource: certFileName, withExtension: "der"),
                           let cert2 = try? Data(contentsOf: cerFilePath)
                        {
                            if cert1.isEqual(to: cert2) {
                                completionHandler(URLSession.AuthChallengeDisposition.useCredential, URLCredential(trust: serverTrust))
                                return
                            }
                        }
                    }
                }
            }
        }

        completionHandler(URLSession.AuthChallengeDisposition.cancelAuthenticationChallenge, nil)
    }
}
