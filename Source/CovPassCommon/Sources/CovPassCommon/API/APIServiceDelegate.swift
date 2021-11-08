//
//  APIServiceDelegate.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation

public final class APIServiceDelegate: NSObject {
    private let publicKeyHashes: [String]

    // MARK: - Creating a Delegate

    /// Initializes an API Session delegate
    /// - Parameter publicKeyHashes: A list of SHA256 hashes of the certificates to pin
    public init(publicKeyHashes: [String]) {
        self.publicKeyHashes = publicKeyHashes
    }
}

extension APIServiceDelegate: URLSessionDelegate {
    public func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        // `serverTrust` not nil implies that authenticationMethod == NSURLAuthenticationMethodServerTrust
        guard let trust = challenge.protectionSpace.serverTrust else {
            // Reject all requests that we do not have a public key to pin for
            completionHandler(.cancelAuthenticationChallenge, /* credential */ nil)
            return
        }

        // Apple's sample code[1] ignores the result of `SecTrustEvaluateAsyncWithError`.
        // We consider it also safe to not check for failures within `SecTrustEvaluateAsyncWithError`
        // that might return something different than `errSecSuccess`.
        //
        // [1]: https://developer.apple.com/documentation/security/certificate_key_and_trust_services/trust/evaluating_a_trust_and_parsing_the_result
        //
        // from the documentation about the method SecTrustEvaluateAsyncWithError
        // Important: You must call this method from the same dispatch queue that you specify as the queue parameter.
        //
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
                completionHandler(.cancelAuthenticationChallenge, /* credential */ nil)
            }
        }
    }

    /// Common evaluation, covering iOS versions 12.5 or 13.x
    /// - Parameters:
    ///   - challenge: A challenge from a server requiring authentication from the client.
    ///   - trust: Shortcut for `challenge.protectionSpace.serverTrust`
    ///   - completionHandler: the completion handler to accept or reject the request
    private func evaluate(challenge: URLAuthenticationChallenge, trust: SecTrust, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        #if DEBUG
            // debug/review: print the chain
            for i in 0 ..< SecTrustGetCertificateCount(trust) {
                if let cert = SecTrustGetCertificateAtIndex(trust, i) {
                    print("certificate chain: [\(challenge.protectionSpace.host)] @ \(i): \(cert)")
                }
            }
        #endif

        if
            let serverCertificate = SecTrustGetCertificateAtIndex(trust, 0),
            let serverPublicKey = SecCertificateCopyKey(serverCertificate),
            let serverPublicKeyData = SecKeyCopyExternalRepresentation(serverPublicKey, nil) as Data?
        {
            // Matching fingerprint?
            let keyHash = serverPublicKeyData.sha256().hexEncodedString()
            if publicKeyHashes.contains(keyHash) {
                // Success! This is our server
                completionHandler(.useCredential, URLCredential(trust: trust))
                return
            } else {
                #if DEBUG
                    print("⛔️ \(keyHash) @ \(challenge.protectionSpace.host)")
                #endif
            }
        }

        completionHandler(.cancelAuthenticationChallenge, /* credential */ nil)
    }
}
