//
//  APIServiceDelegate.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import PromiseKit
import SwiftCBOR

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
                        if let cert2 = try? Data(contentsOf: certUrl) {
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
