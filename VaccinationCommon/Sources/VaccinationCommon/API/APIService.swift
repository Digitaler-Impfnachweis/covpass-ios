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

public enum APIError: Error {
    case requestCancelled
    case compressionFailed
    case invalidUrl
    case invalidReponse
}

public struct APIService: APIServiceProtocol {
    private let url: String
    private let contentType: String = "application/cbor+base45"

    // TODO: rename Encoder to Coder because an encoder does not decode
    private let encoder = Base45Coder()
    private let sessionDelegate: URLSessionDelegate

    public init(sessionDelegate: URLSessionDelegate, url: String) {
        self.sessionDelegate = sessionDelegate
        self.url = url
    }

    public func reissue(_ vaccinationQRCode: String) -> Promise<String> {
        return Promise { seal in
            let code = vaccinationQRCode.stripPrefix()
            let base45Decoded = try encoder.decode(code)
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
                // Check for Error
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

public class APIServiceDelegate: NSObject, URLSessionDelegate {
    private var certUrl: URL

    public init(certUrl: URL) {
        self.certUrl = certUrl
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
                        if let cert2 = try? Data(contentsOf: certUrl)
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
