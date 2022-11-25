//
//  APIServiceDelegate.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation

public final class APIServiceVAASDelegate: NSObject {
    private var publicKeyHashes: [String]

    // MARK: - Creating a Delegate

    public init(publicKeyHashes: [String]) {
        self.publicKeyHashes = publicKeyHashes
    }
}

extension APIServiceVAASDelegate: URLSessionDelegate {
    public func urlSession(_ session: URLSession,
                           didReceive challenge: URLAuthenticationChallenge,
                           completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        guard let trust = challenge.protectionSpace.serverTrust else {
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }

        if #available(iOS 13.0, *) {
            let dispatchQueue = session.delegateQueue.underlyingQueue ?? DispatchQueue.global()
            dispatchQueue.async {
                SecTrustEvaluateAsyncWithError(trust, dispatchQueue) { [weak self] trust, isValid, error in
                    guard isValid else {
                        print("Evaluation failed with error: \(error?.localizedDescription ?? "<nil>")")
                        completionHandler(.cancelAuthenticationChallenge, /* credential */ nil)
                        return
                    }
                    self?.evaluate(challenge: challenge, trust: trust, completionHandler: completionHandler)
                }
            }
        } else {
            var secresult = SecTrustResultType.invalid
            let status = SecTrustEvaluate(trust, &secresult)
            if status == errSecSuccess {
                evaluate(challenge: challenge, trust: trust, completionHandler: completionHandler)
            } else {
                print("Evaluation failed with status: \(status)")
                completionHandler(.cancelAuthenticationChallenge, nil)
            }
        }
    }

    private func evaluate(challenge: URLAuthenticationChallenge,
                          trust: SecTrust,
                          completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        #if DEBUG
            for i in 0 ..< SecTrustGetCertificateCount(trust) {
                if let cert = SecTrustGetCertificateAtIndex(trust, i) {
                    print("certificate chain: [\(challenge.protectionSpace.host)] @ \(i): \(cert)")
                }
            }
        #endif

        if let serverCertificate = SecTrustGetCertificateAtIndex(trust, 1),
           let serverPublicKey = SecCertificateCopyKey(serverCertificate),
           let serverPublicKeyData = SecKeyCopyExternalRepresentation(serverPublicKey, nil) as Data? {
            let keyHash = serverPublicKeyData.sha256().hexEncodedString()
            if publicKeyHashes.contains(keyHash) {
                completionHandler(.useCredential, URLCredential(trust: trust))
                return
            } else {
                #if DEBUG
                    print("⛔️ \(keyHash) @ \(challenge.protectionSpace.host)")
                #endif
            }
        }

        completionHandler(.cancelAuthenticationChallenge, nil)
    }
}
